class LocationsController < ApplicationController
  custom_permission :edit, :create do |url_options, member|
    location = Location.find_by_id_or_instance(url_options[:id], :select => "attachable_type, attachable_id")
    attachable_controller = "#{location.attachable_type.pluralize}Controller".constantize
    location.attachable_id && member && attachable_controller.allowed_to?({:action => 'edit', :id => location.attachable_id}, member)
  end
  
  def edit
    @location = Location.find(params[:id])
  end
  
  def update
    @location = Location.find(params[:id])
    if @location.update_attributes(params[:location])
      redirect_to @location.attachable
    else
      render :action => :edit
    end
  end
  
end