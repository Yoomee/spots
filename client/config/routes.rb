ActionController::Routing::Routes.draw do |map|
  
  map.resources :activities
  map.resources :organisations do |organisation|
    organisation.resources :time_slots, :only => [:index]
    organisation.resources :activities, :only => [:show]
  end
  map.resources :time_slots, :except => [:index]
  map.resources :time_slot_bookings
  
end