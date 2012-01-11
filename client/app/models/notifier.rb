# Copyright 2011 Yoomee Digital Ltd.
# 
# This software and associated documentation files (the
# "Software") was created by Yoomee Digital Ltd. or its agents
# and remains the copyright of Yoomee Digital Ltd or its agents
# respectively and may not be commercially reproduced or resold
# unless by prior agreement with Yoomee Digital Ltd.
# 
# Yoomee Digital Ltd grants Spots of Time (the "Client") 
# the right to use this Software subject to the
# terms or limitations for its use as set out in any proposal
# quotation relating to the Work and agreed by the Client.
# 
# Yoomee Digital Ltd is not responsible for any copyright
# infringements caused by or relating to materials provided by
# the Client or its agents. Yoomee Digital Ltd reserves the
# right to refuse acceptance of any material over which
# copyright may apply unless adequate proof is provided to us of
# the right to use such material.
# 
# The Client shall not be permitted to sub-license or rent or
# loan or create derivative works based on the whole or any part
# of the Works supplied by us under this agreement without prior
# written agreement with Yoomee Digital Ltd.
Notifier.class_eval do
  
  helper :locations

  def activity_passed_organisation(time_slot_booking)
    recipients time_slot_booking.organisation_email
    bcc 'developers@yoomee.com'
    mailing = Mailing.activity_passed_organisation
    from mailing.from
    subject process_substitutions!(mailing.subject.dup, time_slot_booking)
    @body = process_substitutions!(mailing.html_body.dup, time_slot_booking)
    content_type 'text/html'
  end

  def activity_passed_volunteer(time_slot_booking)
    recipients time_slot_booking.member_email
    bcc 'developers@yoomee.com'
    mailing = Mailing.activity_passed_volunteer
    from mailing.from
    subject process_substitutions!(mailing.subject.dup, time_slot_booking)
    @body = process_substitutions!(mailing.html_body.dup, time_slot_booking)
    content_type 'text/html'
  end
  
  def cancel_time_slot_booking(time_slot_booking)
    recipients time_slot_booking.member_email
    bcc 'developers@yoomee.com'
    from APP_CONFIG['site_email']
    subject "Spots of Time: Spot #{time_slot_booking.confirmed? ? 'cancelled' : 'not confirmed'} with #{time_slot_booking.organisation}"
    @time_slot_booking, @recipient = time_slot_booking, time_slot_booking.member
    content_type "multipart/alternative"
    part :content_type => "text/plain", :body => render_message("cancel_time_slot_booking.text.plain", {})
    part :content_type => "text/html", :body => render_message("cancel_time_slot_booking.text.html", {})
  end
  
  def confirm_time_slot_booking(time_slot_booking)
    recipients time_slot_booking.member_email
    bcc 'developers@yoomee.com'
    from APP_CONFIG['site_email']
    subject "Spots of Time: Spot confirmed with #{time_slot_booking.organisation}"
    @time_slot_booking, @recipient = time_slot_booking, time_slot_booking.member
    content_type "multipart/alternative"
    part :content_type => "text/plain", :body => render_message("confirm_time_slot_booking.text.plain", {})
    part :content_type => "text/html", :body => render_message("confirm_time_slot_booking.text.html", {})
  end
  
  def daily_volunteer_list(organisation)
    recipients organisation.email
    bcc 'developers@yoomee.com'
    from APP_CONFIG[:site_email]
    subject "Daily volunteer update for #{organisation}"
    @organisation = organisation
    @confirmed_time_slot_bookings = @organisation.time_slot_bookings.confirmed.starts_at_gt(Time.now).ascend_by_starts_at
    @unconfirmed_time_slot_bookings = @organisation.time_slot_bookings.not_confirmed.starts_at_gt(Time.now).ascend_by_starts_at
    content_type 'multipart/alternative'
    part :content_type => 'text/plain', :body => render_message("daily_volunteer_list.text.plain", {})
    part :content_type => 'text/html', :body => render_message('daily_volunteer_list.text.html', {})
  end

  def email(email)
    recipients email.recipients
    bcc 'developers@yoomee.com'
    from email.from
    subject email.subject
    @body = email.body
    content_type 'text/plain'
  end

  def organisation_signup_for_admin(organisation)
    recipients Member.anna.email
    bcc 'developers@yoomee.com'
    from APP_CONFIG['site_email']
    subject "Spots of Time: New organisation"
    @organisation, @recipient = organisation, Member.anna
    content_type "multipart/alternative"    
    part :content_type => "text/plain", :body => render_message("organisation_signup_for_admin.text.plain", {})
    part :content_type => "text/html", :body => render_message("organisation_signup_for_admin.text.html", {})
  end
  
  def organisation_signup_for_organisation(organisation)
    recipients organisation.email
    bcc 'developers@yoomee.com'
    from APP_CONFIG['site_email']
    subject "Welcome to Spots of Time"
    @organisation, @recipient = organisation, organisation.member
    content_type "multipart/alternative"
    part :content_type => "text/plain", :body => render_message("organisation_signup_for_organisation.text.plain", {})
    part :content_type => "text/html", :body => render_message("organisation_signup_for_organisation.text.html", {}) 
  end
  
  def time_slot_booking_for_organisation(time_slot_booking)
    recipients time_slot_booking.organisation_email
    bcc 'developers@yoomee.com'
    from APP_CONFIG['site_email']
    subject "Spots of Time: New volunteer"
    @time_slot_booking, @recipient = time_slot_booking, time_slot_booking.organisation_member
    content_type "multipart/alternative"    
    part :content_type => "text/plain", :body => render_message("time_slot_booking_for_organisation.text.plain", {})
    part :content_type => "text/html", :body => render_message("time_slot_booking_for_organisation.text.html", {}) 
  end
  
  def time_slot_booking_for_volunteer(time_slot_booking)
    recipients time_slot_booking.member_email
    bcc 'developers@yoomee.com'
    from APP_CONFIG['site_email']
    subject "Spots of Time: #{time_slot_booking.activity} with #{time_slot_booking.organisation}"
    @time_slot_booking, @recipient = time_slot_booking, time_slot_booking.member
    content_type "multipart/alternative"    
    part :content_type => "text/plain", :body => render_message("time_slot_booking_for_volunteer.text.plain", {})
    part :content_type => "text/html", :body => render_message("time_slot_booking_for_volunteer.text.html", {})
  end

  private
  def process_substitutions!(text, time_slot_booking)
    text.gsub!(/\{volunteer_full_name\}/, time_slot_booking.member_name)
    text.gsub!(/\{volunteer_forename\}/, time_slot_booking.member_forename)
    text.gsub!(/\{activity_name\}/, time_slot_booking.activity_name)
    text.gsub!(/\{activity_time\}/, time_slot_booking.starts_at.strftime("%I:%M%p").downcase)
    text.gsub!(/\{activity_date\}/, time_slot_booking.starts_at.strftime("%d %B %Y"))
    text.gsub!(/\{organisation_name\}/, time_slot_booking.organisation_name)
    text.gsub!(/\{confirm_placement_url\}/, "#{APP_CONFIG[:site_url]}/time_slot_bookings/#{time_slot_booking.id}/confirm_attended")
    text.gsub!(/\{thank_you_url\}/, "#{APP_CONFIG[:site_url]}/time_slot_bookings/#{time_slot_booking.id}/organisation_thank_you")
    text
  end
    
end
