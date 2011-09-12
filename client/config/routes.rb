ActionController::Routing::Routes.draw do |map|
  
  map.resources :activities, :collection => {:order => :get, :update_weights => :post} do |activities|
    activities.resources :documents
  end
  map.signup_organisation "/organisations/signup", :controller => "organisations", :action => "signup"  
  map.connect '/organisations/search_address', :controller => 'organisations', :action => 'search_address'
  map.resources :organisations, :member => {:wake => :get, :confirm => :get, :sleep => :get} do |organisation|
    organisation.resources :time_slots, :only => [:index]
    organisation.resources :time_slot_bookings, :only => [:index], :collection => {:in_past => :get}
    organisation.resources :activities, :only => [:show]
  end
  map.resources :time_slots, :except => [:index]
  map.resources :time_slot_bookings, :only => [:create, :update, :show], :member => {:thank_you => :get, :confirm => :get, :cancel => :get}
  map.resources :members, :only => [], :member => {:agree_to_big_print => :put, :edit_bio => :get, :update_bio => :put}
  map.big_print "/big_print", :controller => "members", :action => "big_print"
  
end