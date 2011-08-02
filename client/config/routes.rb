ActionController::Routing::Routes.draw do |map|
  
  map.resources :activities
  map.signup_organisation "/organisations/signup", :controller => "organisations", :action => "signup"  
  map.resources :organisations do |organisation|
    organisation.resources :time_slots, :only => [:index]
    organisation.resources :time_slot_bookings, :only => [:index]
    organisation.resources :activities, :only => [:show]
  end
  map.resources :time_slots, :except => [:index]
  map.resources :time_slot_bookings, :only => [:create], :member => {:thank_you => :get}
  
end