Mailing.class_eval do
  
  class << self
    
    def activity_passed_organisation
      find_by_name('activity_passed_organisation')
    end
    
    def activity_passed_volunteer
      find_by_name('activity_passed_volunteer')
    end
  
  end
      
end