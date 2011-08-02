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
  map.resources :members, :only => [], :member => {:agree_to_big_print => :put}
  map.big_print_path "/big_print", :controller => "members", :action => "big_print"
  
end