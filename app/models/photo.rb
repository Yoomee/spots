require 'forwardable'
class Photo < ActiveRecord::Base

  extend Forwardable
  include Media
  include TramlinesImages
  
  search_attributes %w{name description}
  
  belongs_to :photo_album
  alias_attribute :album, :photo_album #, :auto_save => true
  has_many :news_feed_items, :as => :attachable, :dependent => :destroy
  
  before_validation :create_album_if_needed
  after_validation_on_create :resize_down

  # Shouldn't validate image file size, as it will be sized down after creation
  validates_presence_of :photo_album
  validates_presence_of :image
  
  named_scope :system_photos, :joins => :photo_album, :conditions => {:photo_albums => {:system_album => true}}

  #TODO - Could this possibly be improved?
  named_scope :non_system_photos, :conditions => "photo_album_id > 1"
  
  attr_accessor :system_photo
  alias_method :system_photo?, :system_photo

  def_delegator :image, :url
  
  def skip_news_feed_with_system_photo
    return true if system_photo
    skip_news_feed_without_system_photo
  end
  alias_method_chain :skip_news_feed, :system_photo
  
  private
  def create_album_if_needed
    self.build_photo_album(:system_album => system_photo) unless album
  end

  def resize_down
    self.image = image.process!(:resize, APP_CONFIG[:photo_resize_geometry]) if image
  end
  
end
