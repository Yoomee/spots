Notifier.class_eval do
  
  helper :locations
  
  def cancel_time_slot_booking(time_slot_booking)
    recipients time_slot_booking.member_email
    from APP_CONFIG['site_email']
    subject "Spots of Time: Spot #{time_slot_booking.confirmed? ? 'cancelled' : 'not confirmed'} with #{time_slot_booking.organisation}"
    @time_slot_booking, @recipient = time_slot_booking, time_slot_booking.member
    content_type "multipart/alternative"
    part :content_type => "text/plain", :body => render_message("cancel_time_slot_booking.text.plain", {})
    part :content_type => "text/html", :body => render_message("cancel_time_slot_booking.text.html", {})
  end
  
  def confirm_time_slot_booking(time_slot_booking)
    recipients time_slot_booking.member_email
    from APP_CONFIG['site_email']
    subject "Spots of Time: Spot confirmed with #{time_slot_booking.organisation}"
    @time_slot_booking, @recipient = time_slot_booking, time_slot_booking.member
    content_type "multipart/alternative"
    part :content_type => "text/plain", :body => render_message("confirm_time_slot_booking.text.plain", {})
    part :content_type => "text/html", :body => render_message("confirm_time_slot_booking.text.html", {})
  end

  def organisation_signup_for_admin(organisation)
    recipients Member.anna
    from APP_CONFIG['site_email']
    subject "Spots of Time: New organisation"
    @organisation, @recipient = organisation, Member.anna
    content_type "multipart/alternative"    
    part :content_type => "text/plain", :body => render_message("organisation_signup_for_admin.text.plain", {})
    part :content_type => "text/html", :body => render_message("organisation_signup_for_admin.text.html", {})
  end
  
  def organisation_signup_for_organisation(organisation)
    recipients organisation.email
    from APP_CONFIG['site_email']
    subject "Welcome to Spots of Time"
    @organisation, @recipient = organisation, organisation.member
    content_type "multipart/alternative"
    part :content_type => "text/plain", :body => render_message("organisation_signup_for_organisation.text.plain", {})
    part :content_type => "text/html", :body => render_message("organisation_signup_for_organisation.text.html", {}) 
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
  
  def time_slot_booking_for_volunteer(time_slot_booking)
    recipients time_slot_booking.member_email
    from APP_CONFIG['site_email']
    subject "Spots of Time: #{time_slot_booking.activity} with #{time_slot_booking.organisation}"
    @time_slot_booking, @recipient = time_slot_booking, time_slot_booking.member
    content_type "multipart/alternative"    
    part :content_type => "text/plain", :body => render_message("time_slot_booking_for_volunteer.text.plain", {})
    part :content_type => "text/html", :body => render_message("time_slot_booking_for_volunteer.text.html", {})
  end
  
end
