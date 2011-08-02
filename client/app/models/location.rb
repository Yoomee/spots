Location.class_eval do
  
  validates_presence_of :address1, :city, :postcode
  
end