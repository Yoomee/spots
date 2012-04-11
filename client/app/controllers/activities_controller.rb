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
class ActivitiesController < ApplicationController
  
  admin_only :create, :destroy, :edit, :order, :new, :update, :update_weights
  
  before_filter :get_activity, :only => %w{destroy edit show update}
  
  def create
    @activity = Activity.new(params[:activity])
    if @activity.save
      flash[:notice] = "Successfully created activity."
      redirect_to @activity
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @activity.destroy
    flash[:notice] = "Successfully deleted activity."
    redirect_to_waypoint_after_destroy
  end
  
  def edit
  end
    
  def index
    @activities = Activity.all
  end
  
  def new
    @activity = Activity.new
  end

  def order
    @activities = Activity.all
  end
  
  def show
    if @organisation = Organisation.find_by_id(params[:organisation_id])
      if @organisation.active?
        @other_activities = @organisation.activities.id_is_not(@activity.id)
        @panel_organisation = @organisation
      else
        @organisation = nil
        @panel_organisation = @activity.organisations.visible.random.first
      end
    elsif @organisation_group = OrganisationGroup.find_by_id(params[:organisation_group_id])
      @panel_organisation = @activity.organisations.organisation_group_id_is(@organisation_group.id).visible.random.first
    elsif @activity.anytime?
      @other_activities = Activity.anytime.not_including(@activity)
    else
      @panel_organisation = @activity.organisations.visible.random.first
    end
    @selected_date = Date.parse(params[:date]) if params[:date].present?
    if request.xhr?
      render :partial => "activities/organisation_panel", :locals => {:activity => @activity, :organisation => @organisation}
    else
      @search = Search.new
    end
  end
  
  def time_slots
    @organisation = Organisation.find(params[:organisation_id])
    @activity = Activity.find(params[:id])
    if request.xhr?
      @date = Date.parse(params[:date])
      render :update do |page|
        page[:time_slot_list].html(render("time_slots/list", :organisation => @organisation, :activity => @activity, :date => @date))
      end
    else
      @time_slots = @activity.time_slots.organisation_id_is(@organisation.id).ascend_by_starts_at
      @time_slot_booking = TimeSlotBooking.new
    end
  end
  
  def update
    if @activity.update_attributes(params[:activity])
      flash[:notice] = "Successfully updated activity."
      redirect_to @activity
    else
      render :action => 'edit'
    end
  end

  def update_weights
    params[:activities].each do |index, sortable_hash|
      Activity.find(sortable_hash["activity_id"]).update_attribute(:weight, index)
    end
    redirect_to activities_path
  end
  
  private
  def get_activity
    @activity = Activity.find(params[:id])
  end
  
end
