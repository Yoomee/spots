class TimeSlotBookingsController < ApplicationController
  
  member_only :create
  owner_only :thank_you
  
  def create
    @time_slot_booking = logged_in_member.time_slot_bookings.build(params[:time_slot_booking])
    if @time_slot_booking.save
      flash[:notice] = "Great, you are now booked to be at #{@time_slot_booking.organisation_name} #{@time_slot_booking.starts_at_neat_string}"
      redirect_to thank_you_time_slot_booking_path(@time_slot_booking)
    else
      @time_slot = @time_slot_booking.time_slot
      render :template => "time_slots/show"
    end
  end
  
  def thank_you
    @time_slot_booking = TimeSlotBooking.find(params[:id])
  end
  
end