class Blog < ActiveRecord::Base
  
  include TramlinesImages
  
  belongs_to :member
  has_many :authors, :through => :blog_posts, :source => :member, :uniq => true
  has_many :blog_posts

  validates_presence_of :name
  
  alias_attribute :posts, :blog_posts

  class << self
    
    def main
      if blog = Blog.first
        blog
      else
        Blog.create(:name => "Blog")
      end
    end
    
  end

  def breadcrumb
    [self]
  end
  
  def number_of_posts_by(author)
    posts_by(author).size
  end

  def posts_by(author)
    posts.by(author)
  end

  def to_s
    name
  end

end
