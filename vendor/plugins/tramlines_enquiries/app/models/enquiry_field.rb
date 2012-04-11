class EnquiryField < ActiveRecord::Base

  belongs_to :enquiry

  class << self
  
    def email_address
      find_by_name("email_address")
    end
    
  end
  
end
