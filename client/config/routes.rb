ActionController::Routing::Routes.draw do |map|
  
  map.resources :activities
  map.resources :organisations do |organisation|
    organisation.resources :time_slots, :only => [:index]
  end
  map.resources :time_slots, :except => [:index]
  
end