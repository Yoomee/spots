module ActivitiesHelper
  
  def activity_typeize(str)
    str.to_s.fully_underscore.downcase
  end
  
  def get_involved_activities
    @get_involved_activities ||= Activity.all
  end
  
  def get_involved_activity_types
    @get_involved_activity_types ||= OrganisationGroup.with_activities - [OrganisationGroup.find(1)] + ['East London']
  end    
  
end
    