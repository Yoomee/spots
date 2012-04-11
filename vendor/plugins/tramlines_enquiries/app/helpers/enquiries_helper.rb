module EnquiriesHelper
  
  def render_form(enquiry)
    render :partial => 'enquiries/form', :locals => {:enquiry => @enquiry}
  end
  
end