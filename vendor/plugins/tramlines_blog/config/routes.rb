ActionController::Routing::Routes.draw do |map|

  map.resources :blogs do |blog|
    blog.resources :blog_posts
  end
  map.resources :blog_posts  
  map.connect '/blog', :controller => "blogs", :action => "show"
  map.resources :blog_post_categories do |blog_post_category|
    blog_post_category.resources :blog_posts, :only => [:show]
  end
  
end