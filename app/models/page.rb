require 'page_concerns/slugs'
class Page < ActiveRecord::Base

  include PageConcerns::Slugs
  include TramlinesImages

  FORM_TABS = %w{details snippets publishing related_items}
  LOADED_TABS = []
  SUMMARY_LENGTH = 100
  
  belongs_to :photo, :autosave => true
  belongs_to :section

  before_validation :skip_news_feed_for_photo
  before_save :modify_slideshare_urls

  acts_as_taggable
  has_permalink
  has_related_items
  has_snippets
  has_breadcrumb_parent :section

  validates_presence_of :expires_on, :publish_on, :section, :title
  # We can optionally make text not mandatory (for instance in sections)
  validates_presence_of :text, :unless => Proc.new {|page| !page.text_mandatory?}

  named_scope :for_month_and_year, lambda{|month, year| {:conditions => ["MONTH(publish_on)=:month AND YEAR(publish_on)=:year", {:month => month, :year => year}]}}
  named_scope :latest, :order => 'weight, publish_on DESC'
  named_scope :published, lambda{{:conditions => ["publish_on <= :now AND expires_on > :now AND pages.draft = 0", {:now => Time.zone.now}]}}
  named_scope :not_expired, lambda{{:conditions => ["expires_on > :now AND draft = 0", {:now => Time.zone.now}]}}
  named_scope :weighted, :order => 'weight'
  named_scope :with_photo, :conditions => "photo_id IS NOT NULL"
  named_scope :with_root_section_id, lambda{|section_id| {:joins => :section , :conditions => "sections.parent_id = #{section_id}"}}
  named_scope :without_photo, :conditions => {:photo_id => nil}
    
  search_attributes %w{title intro text small_title}, :autocomplete => %w{title small_title}
  
  formatted_time_accessor :publish_on, :expires_on
  
  # Comparator
  def <=> other_page
    if weight != other_page.weight
      weight <=> other_page.weight
    else
      other_page.publish_on <=> publish_on
    end
  end
  
  def ancestors
    [section] + section.ancestors
  end
  
  def breadcrumb
    if !section.nil? && section.respond_to?(:breadcrumb)
      return section.view == 'first_page'&& section.first_page == self ? section.breadcrumb : section.breadcrumb << self
    else
      return section.view == 'first_page'&& section.first_page == self ? [] : [self]
    end
  end
  
  def been_published?
    Time.zone.now >= publish_on && !draft?
  end
  
  def expired?
    Time.zone.now > expires_on
  end
  
  def expires?
    # expires_on < Time.local(2035)
    expires_on != Time.local(2035) && expires_on != Time.gm(2035)
  end
  
  def form_tabs
    self.class::FORM_TABS.dup
  end
  
  def has_photo?
    !photo.nil?
  end
    
  def initialize_with_defaults(attrs = {})
    initialize_without_defaults(attrs) do
      self.publish_on = Time.zone.now if publish_on.nil?
    end
  end
  alias_method_chain :initialize, :defaults
  
  # Not sure what the purpose of this is
  def loaded_tabs
    self.class::LOADED_TABS.dup
  end
  
  # Returns an array of the form [month_number, year_number]
  def publish_month_and_year
    [publish_on.month, publish_on.year]
  end
  
  def published?
    been_published? && !expired? && !draft?
  end
  
  def root_section
    section.root
  end

  def root_section_slug
    root_section.slug
  end

  def small_title
    read_attribute(:small_title).blank? ? title : read_attribute(:small_title)
  end

  def status_string
    now = Time.now
    if draft?
      'This page is a draft'
    elsif publish_on > now
      'This page has not been published yet.'
    elsif expires_on < now
      'This page has now expired.'
    elsif !approved?
      'This page has not been approved.'
    end
  end
  
  def summary(length = SUMMARY_LENGTH, options = {})
    options.reverse_merge!(:strip_tags => false)
    summary_string = has_snippet?(:summary) ? snippet_summary : text
    options[:strip_tags] ? summary_string.strip_tags.word_truncate(length) : summary_string.truncate_html(length)
  end
  
  def summary_fields
    [:text, :intro]
  end
  
  def text=(txt)
    write_attribute(:text, txt)
  end
  
  def text_mandatory?
    true
  end
  
  def to_s
    small_title
  end
  
  # this is overidden in tramlines_events plugin so that page is described as event if need be
  def type_name
    "page"
  end

  # def validate
  #   if !slug.blank? && Section.exists?(:slug => slug)
  #     errors.add(:slug, "is already being used on a section")
  #     false
  #   else
  #     true
  #   end
  # end

  private
  def skip_news_feed_for_photo
    photo.skip_news_feed = true if photo
    true
  end
  
  def modify_slideshare_urls
    self.text = get_slideshare_url(text)
  end

  def get_slideshare_url(text)
    return nil if text.nil?
    text.gsub!(%r{(http://www\.|http://|www\.)slideshare\.net/([^<\s]*)}x) do
      slideshow_path = $2
      if (response = %x{curl -I "http://www.slideshare.net/#{slideshow_path}"}) && (slideshow_id = response.match(/X-Bench-ID: s(\d*)/).try(:[],1))
        puts "replacing #{slideshow_path} with #{slideshow_id}"
        "http://www.slideshare.net/slideshow/embed_code/#{slideshow_id}"
      else
        "http://www.slideshare.net/#{slideshow_path}"
      end
    end   
    text
  end

end
  
