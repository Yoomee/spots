require 'section_concerns/slugs'
class Section < ActiveRecord::Base

  include SectionConcerns::Slugs
  include TramlinesImages

  FORM_TABS = %w{details advanced related_items}
  SUMMARY_LENGTH = 100
  VIEW_OPTIONS = [
    ['Normal', 'normal'],
    ['Latest Stories', 'latest_stories'],
    ['First Page', 'first_page']
  ]
  
  default_scope :order => 'weight, created_at'
  
  belongs_to :parent, :class_name => 'Section', :foreign_key => :parent_id
  belongs_to :photo
  has_many :children, :class_name => 'Section', :foreign_key => :parent_id, :dependent => :destroy, :order => 'weight, created_at'
  has_many :pages, :order => 'weight, publish_on', :dependent => :destroy
  # Section#pages.latest doesn't work, as the latest gets clobbered by the association :order, therefore...
  has_many :latest_pages, :class_name => 'Page', :order => 'weight, publish_on DESC'
  
  has_permalink
  has_related_items
  has_breadcrumb_parent :parent
  
  validates_presence_of :name
  
  named_scope :root, :conditions => {:parent_id => nil}
  named_scope :not_hidden, :conditions => {:hidden => false}
  
  search_attributes %w{name small_name}, :autocomplete => %w{name small_name}

  class << self
    
    def latest_news(limit = 5)
      items = news.pages.published.latest
      items.extend(SectionsController::SortByWeightAndLatest)
      out = items.sort_by_weight_and_latest
      out = out.first(limit) if limit
      out
    end
    
  end
  
  def absolute_root
    ab_root = self
    until !ab_root.parent
      ab_root = ab_root.parent
    end
    ab_root
  end
  
  def all_children(options={})
    pages_to_show = pages
    if options[:published_only]
      pages_to_show = pages_to_show.published
    elsif !options[:show_expired]
      pages_to_show = pages_to_show.not_expired
    end
    pages_to_show = pages_to_show.not_past_events if options[:not_past_events]
    pages_to_show = pages_to_show + (options[:show_hidden] ? children.all : children.not_hidden)
    if options[:latest]
      pages_to_show.extend(SectionsController::SortByWeightAndLatest)
      pages_to_show.sort_by_weight_and_latest    
    else
      pages_to_show.sort_by(&:weight)
    end
  end
  
  def all_descendants(options={})
    descendants = all_children(options)
    children.each do |child|
      descendants << child.all_descendants(options)
    end
    descendants.flatten
  end
  
  def ancestors
    root? ? [] : parent.ancestors.insert(0,parent)
  end
  
  def descendant_generations
    return 0 if children.empty?
    1 + children.map(&:descendant_generations).max
  end
  
  def descendants
    children + children.collect(&:descendants).flatten
  end
  
  def depth
    return 0 if parent.nil?
    1 + parent.depth
  end
  
  def destination
    case view
    when 'first_page'
      all_chldrn = all_children(:published_only => true)
      return self if all_chldrn.empty?
      all_chldrn.first.is_a?(Page) ? all_chldrn.first : all_chldrn.first.destination
    else
      self
    end
  end
  
  def destination_id
    destination.id
  end
  
  def destination_type
    destination.class.to_s.underscore
  end
  
  def first_page
    pages.first
  end
  
  def form_tabs
    self.class::FORM_TABS.dup
  end
  
  # gets parent from number of levels above
  def get_parent(generation_level)
    return self if root? || generation_level <= 0
    parent.get_parent(generation_level-1)
  end
  
  def get_published_pages
    pages.published
  end
  
  def has_descendant?(page_or_section)
    all_descendants.include? page_or_section
  end
  
  def has_photo?
    !photo.nil?
  end
  
  def last_month_and_year
    month_and_years.first
  end
  
  # Returns an array of month and year number in the form [[month_num, year_num], [month_num, year_num], ...]
  def month_and_years
    sorted_pages = get_published_pages.sort_by {|page| page.publish_on}.reverse
    sorted_pages.map {|page| page.publish_month_and_year}.uniq
  end
  
  def num_parents
    return 0 if root?
    1 + parent.num_parents
  end
  
  def page_and_section_descendant_generations
    return 0 if all_children.empty?
    1 + (children.map(&:page_and_section_descendant_generations).max || 0)
  end
  
  def parent_at_depth(depth)
    return self if self.depth == depth
    if parent
      parent.parent_at_depth(depth)
    else
      nil
    end
  end
  
  def parent_at_depth_name(depth)
    parent_at_depth(depth).try(:name) || ''
  end
  
  def root
    parent ? parent.root : self
  end

  def root?
    parent.nil?
  end

  def small_name
    read_attribute(:small_name).blank? ? name : read_attribute(:small_name)
  end
  
  def subnav_children(options = {})
    if view == 'news_view'
      pages_and_sections = all_children(options)
      pages_and_sections.extend(SectionsController::SortByWeightAndPublished)
      pages_and_sections.sort_by_weight_and_published
    else
      all_children(options)
    end
  end

  def summary(length = SUMMARY_LENGTH, options = {})
    options.reverse_merge!(:strip_tags => false)
    return "" if description.blank?
    options[:strip_tags] ? description.strip_tags.word_truncate(length) : description.truncate_html(length)
  end
  
  def to_s
    small_name
  end
  
end
