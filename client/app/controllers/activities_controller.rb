class ActivitiesController < ApplicationController
  
  admin_only :create, :new, :edit, :destroy, :update
  
  before_filter :get_activity, :only => %w{edit destroy show update}
  
  def index
    @activities = Activity.all
  end
  
  def show
  end
  
  def new
    @activity = Activity.new
  end
  
  def create
    @activity = Activity.new(params[:activity])
    if @activity.save
      flash[:notice] = "Successfully created activity."
      redirect_to @activity
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @activity.update_attributes(params[:activity])
      flash[:notice] = "Successfully updated activity."
      redirect_to @activity
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @activity.destroy
    flash[:notice] = "Successfully deleted activity."
    redirect_to_waypoint_after_destroy
  end
  
  private
  def get_activity
    @activity = Activity.find(params[:id])
  end
  
end
