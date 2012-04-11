class BlogPostCategory < ActiveRecord::Base
  
  belongs_to :member
  
  has_and_belongs_to_many :blog_posts
  
  validates_presence_of :name
  validates_uniqueness_of :name  
  
end
