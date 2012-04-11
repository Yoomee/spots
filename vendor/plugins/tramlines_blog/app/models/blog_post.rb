class BlogPost < ActiveRecord::Base

  include TramlinesImages
  
  has_wall
  has_permalink
  
  belongs_to :blog
  belongs_to :member
  belongs_to :photo, :autosave => true  
  has_and_belongs_to_many :blog_post_categories, :order => 'name'
  
  validates_presence_of :title, :text, :blog, :blog_id

  named_scope :by, lambda{|author| {:conditions => {:member_id => author.id}}}
  named_scope :most_recent, :order => 'created_at DESC'

  alias_attribute :author, :member
  alias_attribute :categories, :blog_post_categories
  alias_attribute :name, :title
  
  
  def breadcrumb
    blog.breadcrumb + [self]
  end
  
  def has_photo?
    !photo.nil?
  end
  
  def to_s
    title
  end

end
