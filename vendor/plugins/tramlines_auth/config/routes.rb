ActionController::Routing::Routes.draw do |map|
  
  map.resource :session, :only => [], :member => {:create_fb => :any}
  map.connect "/auth/:provider/callback", :controller => "sessions", :action => "auth_create"
  map.controller "/auth/failure", :controller => "sessions", :action => "auth_failure"
  
  map.connect "/me", :controller => "members", :action => "me"
  
end