# Copyright 2011 Yoomee Digital Ltd.
# 
# This software and associated documentation files (the
# "Software") was created by Yoomee Digital Ltd. or its agents
# and remains the copyright of Yoomee Digital Ltd or its agents
# respectively and may not be commercially reproduced or resold
# unless by prior agreement with Yoomee Digital Ltd.
# 
# Yoomee Digital Ltd grants Spots of Time (the "Client") 
# the right to use this Software subject to the
# terms or limitations for its use as set out in any proposal
# quotation relating to the Work and agreed by the Client.
# 
# Yoomee Digital Ltd is not responsible for any copyright
# infringements caused by or relating to materials provided by
# the Client or its agents. Yoomee Digital Ltd reserves the
# right to refuse acceptance of any material over which
# copyright may apply unless adequate proof is provided to us of
# the right to use such material.
# 
# The Client shall not be permitted to sub-license or rent or
# loan or create derivative works based on the whole or any part
# of the Works supplied by us under this agreement without prior
# written agreement with Yoomee Digital Ltd.
ActionController::Routing::Routes.draw do |map|
  
  map.resources :activities, :collection => {:order => :get, :update_weights => :post} do |activities|
    activities.resources :documents
  end
  map.signup_organisation "/organisations/signup", :controller => "organisations", :action => "signup"  
  map.signup_organisation_with_ref "/organisations/signup/:ref", :controller => "organisations", :action => "signup"  
  map.connect '/organisations/search_address', :controller => 'organisations', :action => 'search_address'
  map.resources :organisation_groups do |organisation_group|
    organisation_group.resources :activities, :only => [:show]
    organisation_group.resources :organisations, :only => [:index, :new]
  end
  map.resources :organisations, :member => {:wake => :get, :confirm => :get, :sleep => :get} do |organisation|
    organisation.resources :documents
    organisation.resources :time_slots, :only => [:index]
    organisation.resources :time_slot_bookings, :only => [:index], :collection => {:in_past => :get}
    organisation.resources :activities, :only => [:show], :member => {:time_slots => :get}
  end
  map.resources :time_slots, :except => [:index] do |time_slot|
    time_slot.resources :time_slot_bookings, :only => [:new]
  end
  map.resources :time_slot_bookings, :only => [:create, :update, :show], :member => {:thank_you => :get, :confirm => :get, :confirm_attended => :get, :cancel => :get} do |time_slot_bookings|
    time_slot_bookings.resource :thank_you_mail
  end
  map.resources :members, :only => [], :member => {:agree_to_big_print => :put, :edit_bio => :get, :update_bio => :put}
  map.welcome '/welcome', :controller => 'members', :action => 'welcome'
  map.big_print "/big_print", :controller => "members", :action => "big_print"
  map.connect '/widget', :controller => 'widget', :action => 'index'
  
end
