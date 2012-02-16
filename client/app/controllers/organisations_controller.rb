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
class OrganisationsController < ApplicationController
 
  admin_only :confirm, :sleep, :wake
  member_only :new
  owner_only :destroy, :edit, :update
  
  before_filter :get_organisation, :only => %w{confirm destroy edit show sleep update wake}

  class << self
  
    def allowed_to_with_confirmation?(url_options, member)
      return false if !allowed_to_without_confirmation?(url_options, member)
      if url_options[:action] == 'show'
        return true if member.try(:is_admin?)
        organisation = Organisation.find(url_options[:id])
        organisation.active? || organisation.owned_by?(member)
      else
        true
      end
    end
    alias_method_chain :allowed_to?, :confirmation

  end

  def confirm
    @organisation.update_attribute(:confirmed, true)
    flash[:notice] = "#{@organisation} has now been confirmed"
    redirect_to_waypoint
  end
  
  def create
    if admin_logged_in? || logged_out?
      @organisation = Organisation.new(params[:organisation])
    else
      @organisation = logged_in_member.organisations.build(params[:organisation])
    end
    if @organisation.save
      if admin_logged_in?
        flash[:notice] = "Successfully created organisation."
        redirect_to @organisation
      else
        flash[:notice] = "Thanks for signing up! Now enter some activites, you can do this later if you want."
        session[:logged_in_member_id] = @organisation.member_id
        redirect_to organisation_time_slots_path(@organisation, :signup => true)
      end
    else
      puts @organisation.errors.full_messages.inspect
      render :action => logged_in? ? 'new' : 'signup'
    end
  end
  
  def destroy
    @organisation.destroy
    flash[:notice] = "Successfully deleted organisation."
    redirect_to_waypoint_after_destroy
  end

  def edit
    set_default_lat_lng
  end
  
  def index
    @organisation_group = OrganisationGroup.find_by_id(params[:organisation_group_id])
    @organisations = @organisation_group ? @organisation_group.organisations : Organisation.all
  end
  
  def new
    @organisation = Organisation.new(:organisation_group_id => params[:organisation_group_id])
    set_default_lat_lng
  end
  
  def search_address
    if params[:lat] && params[:lng]
      lat, lng = params[:lat], params[:lng]
    else
      lat, lng = GoogleGeocode::get_lat_lng(params[:address])
    end
    if lat && lng
      @activity = Activity.find(params[:activity_id])
      centre = Location.new(:lat => lat, :lng => lng)
      if @organisation = Organisation.visible.with_activity(@activity).within_distance_of(centre, SEARCH_MILE_RADIUS).nearest_to(centre).first
        html = @template.render("activities/organisation_panel", :activity => @activity, :organisation => @organisation, :lat => lat, :lng => lng)
        return render(:json => {:lat => @organisation.lat, :lng => @organisation.lng, :organisation_id => @organisation.id, :organisation_html => html})
      else
        render :json => {:no_results => true, :lat => lat, :lng => lng}        
      end
    else
      render :json => {:unknown_location => true}
    end
  end

  def show
  end
  
  def signup
    if logged_in?
      render_404
    else
      @organisation = Organisation.new(:organisation_group => OrganisationGroup.find_by_ref(params[:ref]))
      @organisation.build_member
    end
  end
  
  def sleep
    @organisation.update_attribute(:awake, false)
    flash[:notice] = "This organisation is now sleeping and will not show on any activity pages."
    redirect_to @organisation
  end
  
  def update
    if @organisation.update_attributes(params[:organisation])
      flash[:notice] = "Successfully updated organisation."
      redirect_to @organisation
    else
      render :action => 'edit'
    end
  end
  
  def wake
    @organisation.update_attribute(:awake, true)
    flash[:notice] = "This organisation has now been re-activated"
    redirect_to @organisation
  end
  
  private
  def get_organisation
    @organisation = Organisation.find(params[:id])
  end
  
  def set_default_lat_lng
    @organisation.location.lat ||= Location::DEFAULT_CENTER[0]
    @organisation.location.lng ||= Location::DEFAULT_CENTER[1]
  end
  
end
OrganisationsController::SEARCH_MILE_RADIUS = 20