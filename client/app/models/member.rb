Member.class_eval do
  
  has_many :organisations, :dependent => :nullify
  
  has_wall
  
end