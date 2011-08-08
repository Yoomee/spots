Notifier.class_eval do
  
  helper :locations
  
  def time_slot_booking_for_volunteer(time_slot_booking)
    recipients time_slot_booking.member_email
    from APP_CONFIG['site_email']
    subject "Spots of Time: #{time_slot_booking.activity} with #{time_slot_booking.organisation}"
    @time_slot_booking, @recipient = time_slot_booking, time_slot_booking.member
    content_type "multipart/alternative"    
    part :content_type => "text/plain", :body => render_message("time_slot_booking_for_volunteer.text.plain", {})
    part :content_type => "text/html", :body => render_message("time_slot_booking_for_volunteer.text.html", {})
  end
  
  def time_slot_booking_for_organisation(time_slot_booking)
    recipients time_slot_booking.organisation_email
    from APP_CONFIG['site_email']
    subject "Spots of Time: New volunteer"
    @time_slot_booking, @recipient = time_slot_booking, time_slot_booking.organisation_member
    content_type "multipart/alternative"    
    part :content_type => "text/plain", :body => render_message("time_slot_booking_for_organisation.text.plain", {})
    part :content_type => "text/html", :body => render_message("time_slot_booking_for_organisation.text.html", {}) 
  end
  
end