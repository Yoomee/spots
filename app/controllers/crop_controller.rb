class CropController < ApplicationController
  
  admin_only :edit, :update
  
  before_filter :get_object
  
  def edit
    
  end
  
  def update
    @object.update_attributes(params[@object.class.to_s.underscore])
    redirect_to_waypoint
  end
  
  private
  def get_object
    @object = params[:model_name].camelize.constantize.find(params[:id])
  end
  
end