Mailing.class_eval do
  
  class << self
    
    def activity_passed_volunteer
      find_or_create_by_name('activity_passed_volunteer')
    end
  
  end
      
end