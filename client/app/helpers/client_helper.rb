module ClientHelper
  def day_name(short)
    {:mon => "Monday",:tue => "Tuesday",:wed => "Wednesday", :thu => "Thursday", :fri => "Friday", :sat => "Saturday", :sun => "Sunday"}[short]
  end
  def organisation_infobox(organisation)
    "<strong>#{organisation}</strong><br/>#{render_address(organisation.location,:multi_line=> true)}"
  end
  
  def organisation_marker_click(organisation)
    "ActivityMap.fetchOrganisation(#{@activity.id},#{organisation.id});"
  end
  
  
end