class TimeSlotBookingsController < ApplicationController
  
  member_only :create
  
  def create
    @time_slot_booking = logged_in_member.time_slot_bookings.build(params[:time_slot_booking])
    if @time_slot_booking.save
      flash[:notice] = "Great, you are now booked to be at #{@time_slot_booking.organisation_name} #{@time_slot_booking.starts_at.strftime('on %d %b at %H:00')}"
      redirect_to @time_slot_booking.organisation
    else
      @time_slot = @time_slot_booking.time_slot
      render :template => "time_slots/show"
    end
  end
  
end