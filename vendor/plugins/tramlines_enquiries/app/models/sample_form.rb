module SampleForm
  
  include EnquiryForm
  
  email_from "info@yoomee.com"
  email_subject 'New Contact form submission'
  email_to "si@yoomee.com"
  fields :name, :email_address, :message
  response_message 'Thank you for getting in touch'
  title "Contact us"
  
end
