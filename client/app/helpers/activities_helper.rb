module ActivitiesHelper
  
  def activity_filter_link(organisation_group_or_string)
    link_text = organisation_group_or_string
    organisation_group = organisation_group_or_string.is_a?(String) ? nil : organisation_group_or_string
    active = @organisation_group == organisation_group
    link_to_function(link_text, "ActivityFilter.selectFilter('#{organisation_group.try(:id) || link_text.urlify.downcase}')", :class => "activity_type#{active ? ' active' : ''}", :"data-filter" => (organisation_group.try(:id) || link_text.urlify.downcase))
  end
  
end