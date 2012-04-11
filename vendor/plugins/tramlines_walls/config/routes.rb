ActionController::Routing::Routes.draw do |map|

  map.resources :walls do |wall|
    wall.resources :wall_posts, :collection => {:older => :get}
  end
  
  map.resources :wall_posts
  
end