module ActivitiesHelper
  
  def activity_typeize(str)
    str.to_s.fully_underscore.downcase
  end
  
end
    