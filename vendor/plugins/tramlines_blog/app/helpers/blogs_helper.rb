module BlogsHelper
  
  def viewing_blog?
    controller_name.in? %w{blogs blog_posts}
  end
  alias_method :in_blog?, :viewing_blog?
  
end