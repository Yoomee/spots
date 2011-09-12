HomeController.class_eval do
  
  def index
    @blog_post = BlogPost.latest.first
  end
  
end