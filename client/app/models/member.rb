Member.class_eval do
  
  has_many :organisations, :dependent => :nullify
  has_many :time_slot_bookings, :dependent => :destroy
    
  has_wall
  
end