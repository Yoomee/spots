module ClientHelper
  def organisation_infobox(organisation)
    "<strong>#{organisation}</strong><br/>#{render_address(organisation.location,:multi_line=> true)}"
  end
  
  
end