ActionController::Routing::Routes.draw do |map|

  map.resource :geocode, :only => [:show]
  map.resources :locations, :only => [:edit, :update]
 
end