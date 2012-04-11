class PhotoAlbum < ActiveRecord::Base
  
  UNTITLED_NAME = "Untitled Album"
  
  include TramlinesImages
  
  belongs_to :attachable, :polymorphic => true
  has_many :photos, :dependent => :destroy

  after_save :create_photos
  before_validation :set_name_as_untitled

  named_scope :non_system, :conditions => {:system_album => false}
  named_scope :system_albums, :conditions => {:system_album => true}
  named_scope :untitled, :conditions => "name LIKE '#{UNTITLED_NAME}%'"
  named_scope :without_attachable, :conditions => {:attachable_id => nil}
  
  validates_presence_of :name
  validates_length_of :image_files, :maximum => 20, :message => "can only select 20 images", :allow_nil => true

  attr_accessor :image_files

  accepts_nested_attributes_for :photos, :allow_destroy => true

  class << self
    
    def default_image(image_attr = 'image')
      Photo.default_image(image_attr)
    end
    
  end

  def image
    photos.first.try(:image)
  end
  
  def member
    attachable.is_a?(Member) ? attachable : nil
  end
  
  def owner?(member)
    member && self.member==member
  end
  
  def to_s
    name
  end
  
  def validate
    return true if image_files.nil?
    if image_files.any? {|image_file| !Photo.new(:image => image_file).fields_valid?(:image)}
      errors.add(:image_files, "only image files are allowed")
    end
  end
  
  private
  # TODO: check that this works correctly when creating a member's first photo_album from photos/new
  def set_name_as_untitled
    if name.blank?
      untitled_count = attachable ? attachable.photo_albums.untitled.size : self.class.without_attachable.untitled.size
      self.name = "#{UNTITLED_NAME} #{untitled_count + 1}"
    end
    true
  end
  
  def create_photos
    return true if image_files.nil?
    image_files.each do |image_file|
      photos.create(:image => image_file, :member => member)
    end
  end
  
end
