require 'hpricot'
require 'open-uri'
class Link < ActiveRecord::Base
  
  include Media
  include TramlinesImages
  include Simplificator::Webthumb

  search_attributes %w{name url title description}
  
#  before_save :revert_url_error_if_url_unchanged
  
  validates_presence_of :url
  validates_url_format_of :url
  
  has_many :photo_albums, :as => :attachable, :dependent => :destroy

  attr_accessor :url_changed, :save_site_info
  alias_method :url_changed?, :url_changed
  alias_method :save_site_info?, :save_site_info

  def description_blank?
    read_attribute(:description).blank?
  end
  
  def has_description?
    !description_blank?
  end

  def description
    description_blank? ? "No description" : read_attribute(:description)
  end

  def get_meta_data
    begin
      page = Hpricot open(url)
      title_element = page.at('title')
      description_element = page.at("meta[@name='description']")    
      self.title = title_element.nil? ? url : title_element.inner_html.to_s.strip
      self.description = description_element.nil? ? "" : description_element['content']
      true
    rescue
      self.url_error = true
      false
    end
  end

  def get_webthumb
    begin
      wt = Webthumb.new(APP_CONFIG['webthumb_key'])
      job = wt.thumbnail(:url => url)
      self.image = job.fetch_when_complete(:large)
      true
      # TODO: look into using Easythumb for speed
      # et = Easythumb.new(APP_CONFIG['webthumb_key'], '10327')
      # self.image = open(et.build_url(:url => url, :size => :large, :cache => 1))
      # true
    rescue
      self.url_error = true
      false
    end
  end

  def name
    read_attribute(:name).blank? ? url.gsub(/https?:\/\//, '') : read_attribute(:name)    
  end
  
  def url=(value)
    value = 'http://' + value unless value.blank? || value =~ /^http/
    write_attribute(:url, value.strip)
    self.url_changed = changed.include?('url')
  end

  def save_site_info!
    get_webthumb if get_meta_data
    save
  end

  def summary_fields
    [:description]
  end
  
  private
  def revert_url_error_if_url_unchanged
    self.url_error = url_error_was if !url_changed?
    true
  end
  
end