class TimeSlotsController < ApplicationController
  
  custom_permission :index do |url_options, member|
    organisation = Organisation.find(url_options[:organisation_id])
    organisation.owned_by?(member) || member.is_admin?
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
      page["activity_#{activity.id}_time_slot_form"].replace(render("time_slots/form", :time_slot => @time_slot))
    end
  end
  
end