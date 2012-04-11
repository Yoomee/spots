class Share < Tableless
  
  validates_presence_of :name, :email, :recipient_email
  validates_format_of :email, :with => EMAIL_FORMAT, :allow_blank => false
  validates_format_of :recipient_email, :with => EMAIL_FORMAT, :allow_blank => false
  
  attr_accessor :email, :name, :recipient_email
  
end