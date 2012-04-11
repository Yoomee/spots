module AdminHelper
  
  def admin_tab_heading(tab, selected)
    content_tag(:li, :class => tab == selected ? 'active' : '', :id => "#{tab.name.parameterize('_')}_admin_tab") do
      link_to tab.name, :tab_name => tab.name
    end
  end
  
end
