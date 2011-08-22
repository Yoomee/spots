Member.class_eval do
  
  has_many :organisations, :dependent => :nullify
  has_many :time_slot_bookings, :dependent => :destroy
    
  has_wall
  
  validates_numericality_of :phone, :allow_blank => true
  
  class << self
    
    def anna
      Member.find_by_email("anna@spotsoftime.org.uk")
    end
    
  end
  
end