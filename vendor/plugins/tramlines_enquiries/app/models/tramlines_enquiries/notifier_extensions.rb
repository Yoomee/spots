module TramlinesEnquiries::NotifierExtensions
  
  def enquiry_notification enquiry
    site_name = APP_CONFIG['site_name']
    site_url = APP_CONFIG['site_url']
    recipients enquiry.email_to
    from enquiry.email_from
    bcc "support@yoomee.com"
    subject enquiry.email_subject
    content_type  "multipart/alternative"
    locals = {:enquiry => enquiry, :site_name => site_name, :site_url => site_url}
    part :content_type => "text/plain", :body => render_message("enquiry_notification.text.plain", locals)
    part :content_type => "text/html", :body => render_message("enquiry_notification.text.html", locals)
  end

end
