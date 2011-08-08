class TimeSlotBookingsController < ApplicationController
  
  member_only :create
  owner_only :thank_you
  custom_permission :index do |url_options, member|
    organisation = Organisation.find(url_options[:organisation_id])
    organisation.owned_by?(member) || (member && member.is_admin?)
  end
  
  def create
    @time_slot_booking = logged_in_member.time_slot_bookings.build(params[:time_slot_booking])
    if @time_slot_booking.save
      flash[:notice] = "Thanks #{logged_in_member.forename}, you are now booked to be at #{@time_slot_booking.organisation_name} on #{@time_slot_booking.starts_at_neat_string}"
      redirect_to thank_you_time_slot_booking_path(@time_slot_booking)
    else
      @time_slot = @time_slot_booking.time_slot
      render :template => "time_slots/show"
    end
  end
  
  def index
    @organisation = Organisation.find(params[:organisation_id])
    @time_slot_bookings = @organisation.time_slot_bookings.ascend_by_starts_at
  end
  
  def thank_you
    @time_slot_booking = TimeSlotBooking.find(params[:id])
  end
  
end