class ThankYouMailsController < ApplicationController

  custom_permission :new, :create do |url_options, member|
    time_slot_booking = TimeSlotBooking.find(url_options[:time_slot_booking_id])
    time_slot_booking.in_past? && (time_slot_booking.organisation.owned_by?(member) || (member && member.is_admin?))
  end
  
  expose(:time_slot_booking)
  expose(:thank_you_mail) do
    out = time_slot_booking.thank_you_mail
    out.attributes = params[:thank_you_mail] if params[:thank_you_mail]
    out
  end
  
  def create
    if thank_you_mail.valid?
      Notifier.deliver_email(thank_you_mail)
    else
      render :action => 'new'
    end
  end
  
  def new
  end
  
end