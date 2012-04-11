module TramlinesBlog::MemberExtensions

  def self.included(klass)
    klass.has_many :blog_posts
    klass.has_many :blogs
  end

end
