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
      @other_activities = @organisation.activities.id_is_not(@activity.id)
    elsif @activity.anytime?
      @other_activities = Activity.anytime.not_including(@activity)
    else
      @panel_organisation = @activity.organisations.visible.random.first
    end
    if request.xhr?
      render :partial => "activities/organisation_panel", :locals => {:activity => @activity, :organisation => @organisation}
    else
      @search = Search.new
    end
  end
  
  def time_slots
    @organisation = Organisation.find(params[:organisation_id])
    @activity = Activity.find(params[:id])
    @time_slots = @activity.time_slots.organisation_id_is(@organisation.id).ascend_by_starts_at
    @time_slot_booking = TimeSlotBooking.new
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
