class Wall < ActiveRecord::Base

  belongs_to :attachable, :polymorphic => true
  has_many :wall_posts, :order => 'created_at DESC', :dependent => :destroy
  has_many :members_who_posted, :through => :wall_posts, :source => :member
  
  alias_method :members_who_commented, :members_who_posted
  
  delegate :average_rating, :to => :attachable, :prefix => true
  
  class << self

    def unique_name base
      cnt = 0
      wall_name = base
      while(self.exists?(:name => wall_name))
        cnt += 1
        wall_name = "#{base} (#{cnt})"
      end
      wall_name
    end
    
  end
  
  def attachable_rated_by?(member)
    return false if attachable.nil?
    attachable.is_rateable? ? attachable.rated_by?(member) : false
  end
  
  def has_posts?
    !self.wall_posts.count.zero?
  end
  alias_method :has_comments?, :has_posts?
  
  def is_member_wall?
    attachable.is_a? Member
  end
  
  def older_posts(options = {})
    if options[:get_all]
      posts = wall_posts.latest.paginate(:page => options[:page], :per_page => wall_posts.count)
      posts.slice!(0, options[:per_page].to_i)
      posts
    else
      wall_posts.latest.paginate(:page => options[:page], :per_page => options[:per_page])
    end
  end
  
end