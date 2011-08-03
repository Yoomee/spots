class TimeSlotsController < ApplicationController

  skip_before_filter :redirect_to_organisation_terms, :only => %w{index create update destroy}
  
  custom_permission :index do |url_options, member|
    organisation = Organisation.find(url_options[:organisation_id])
    organisation.owned_by?(member) || (member && member.is_admin?)
  end
  
  custom_permission [:update, :destroy] do |url_options, member|
    time_slot = TimeSlot.find(url_options[:id])
    time_slot.organisation.owned_by?(member) || (member && member.is_admin?)
  end
  
  def index
    @organisation = Organisation.find(params[:organisation_id])
  end
  
  def create
    @time_slot = TimeSlot.new(params[:time_slot])
    activity = @time_slot.activity
    render :update do |page|
      if @time_slot.save
        page["activity_#{activity.id}_time_slots"].append(render("time_slots/time_slot", :time_slot => @time_slot))
        @time_slot = activity.time_slots.build(:organisation => @time_slot.organisation)
      end
      page["activity_#{activity.id}_time_slot_form"].replace(render("time_slots/form", :time_slot => @time_slot, :disabled => false))
      page << "#{labelify_javascript(:script_tag => false)};TimeSlot.setAllSelected();"
    end
  end
  
  def destroy
    @time_slot = TimeSlot.find(params[:id])
    unique_id = "activity_#{@time_slot.activity_id}_time_slot_#{@time_slot.id}"
    render :update do |page|
      if @time_slot.destroy
        page[unique_id].remove
      end
    end
  end
  
  def show
    @time_slot = TimeSlot.find(params[:id])
    @time_slot_booking = @time_slot.bookings.build
  end
  
  def update
    @time_slot = TimeSlot.find(params[:id])
    activity = @time_slot.activity
    render :update do |page|
      if @time_slot.update_attributes(params[:time_slot])
        page["activity_#{activity.id}_time_slot_#{@time_slot.id}"].replace(render("time_slots/time_slot", :time_slot => @time_slot))
      else
        page["activity_#{activity.id}_time_slot_form_#{@time_slot.id}"].replace(render("time_slots/form", :time_slot => @time_slot, :disabled => false))
      end
      page << "#{labelify_javascript(:script_tag => false)};TimeSlot.setAllSelected();"
    end
  end
  
end