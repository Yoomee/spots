if File.exists?("#{RAILS_ROOT}/client/config/routes.rb")
  require "#{RAILS_ROOT}/client/config/routes.rb"
end
ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  map.home '', :controller => 'home'
  map.resource :session, :member => {:morph => :post, :set_waypoint => :post}
  map.set_login_waypoint "session/set_login_waypoint", :controller => "sessions", :action => "set_login_waypoint"
  
  map.resend_password "members/resend_password", :controller => "members", :action => "resend_password"
  map.connect "members/resend_password_to_member", :controller => "members", :action => "resend_password_to_member"
  map.resources :members, :member => {:change_password => :get, :update_password => :put, :json => :get}, :collection => {:autocomplete => :get} do |member|
    member.resources :links
    member.resources :videos
    member.resource :media_library, :controller => 'media_library'
    member.resource :member_photo, :controller => "member_photo"
  end
  map.resources :attachables, :as => :members, :class => "Member" do |member|
    member.resources :photo_albums
  end
  map.resources :sections, :has_many => [:sections, :pages], :collection => {:order => :get, :update_weights => :post}, :member => {:order => :get}
  map.connect "sections/archive/:id", :controller => "sections", :action => "archive"
  map.connect "sections/archive/:id/:year/:month", :controller => "sections", :action => "archive"
  map.connect "sections/rss/:id", :controller => "sections", :action => "rss"
  map.resources :pages
  
  map.resource :notifier
  
  map.super '/super', :controller => 'super'
  
  map.resources :mails, :member => {:read => :get, :send_email => :get}
  map.resources :mailings, :member => {:send_emails => :get}, :collection => {:update_progress => :get} do |mailing|
    mailing.resources :mails
  end
  
  map.resources :links, :member => {:save_info => :put}
  map.resources :videos
  map.resources :photos
  map.resources :photo_albums do |photo_album|
    photo_album.resources :photos, :collection => {:ajax => :get}
  end
  map.resources :searches, :controller => :search, :as => :search, :collection => {:jquery_autocomplete => :get}, :new => {:formtastic_autocomplete => :get}
  map.resources :document_folders do |document_folder|
    document_folder.resources :documents
  end
  # map.connect 'documents', :controller => 'document_folders', :action => 'index'
  map.resources :documents
  map.resources :statuses
  map.resources :news_feed_items, :collection => {:older => :get}
  map.resources :reports
  map.resources :tags, :collection => {:autocomplete => :get}

  map.resource :forgotten_password, :controller => "forgotten_password"

  map.wireframes '/wireframes', :controller => 'wireframes', :action => 'index'
  map.wireframe '/wireframes/:id', :controller => 'wireframes', :action => 'show'
  
  map.connect 'share/create/:id', :controller => 'share', :action => 'create'
  map.connect 'share/:model_name/:id/options', :controller => 'share', :action => 'options'
  map.connect 'share/:model_name/:id', :controller => 'share', :action => 'new'
  
  map.new_crop 'crop/:model_name/:id', :controller => 'crop', :action => 'edit', :conditions => {:method => :get}
  map.crops 'crop/:model_name/:id', :controller => 'crop', :action => 'update', :conditions => {:method => :put}
  
  map.connect 'logged-out', :controller => 'home'
  map.admin '/admin', :controller => 'admin'

  map.login '/login', :controller => 'sessions', :action => 'new'
  map.sitemap '/sitemap', :controller => 'sections'

  map.connect 'member/:action', :controller => "members"
  
  map.tweets 'tweets/:screen_name', :controller => "tweets", :action => "index"

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  #map.root :home
  map.root :controller => 'home'

  # See how all your routes lay out with "rake routes"
  
  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
