module LocationHelper

  def current_root_section
    current_section.nil? ? nil : current_section.absolute_root
  end

  def current_root_section?(section_id)
    current_section?(section_id, :root => true)
  end
  
  def current_section(options = {})
    case
      when @section && @section.is_a?(Section) && @section.id
        current_section = @section
      when @page && @page.is_a?(Page) && @page.id
        current_section = @page.section
      else
        nil
    end
  end
  
  def current_section?(section_id, options = {})
    section_id = section_id.id unless section_id.is_a?(Integer) || section_id.nil?
    return false if section_id.nil?
    section = options[:root] ? current_root_section : current_section
    section.nil? ? false : (section_id == section.id)
  end
  
  def current_section_tree?(section, test_against = current_section)
    return false if section.nil? || test_against.nil?
    section == test_against || current_section_tree?(section, test_against.parent)
  end
  
  # Depends on @is_home being set in controller
  def is_home?
    @is_home
  end
  
  def render_subnav(section = current_section, depth_to_show = nil, last_row = true, bottom_normal_subnav = true)
    return "" if section.nil?
    depth = section.depth
    if (section.subnav_children.size < 2) || (depth_to_show && depth_to_show != depth)
      out = ''
      last_row = true
    else
      overflow = action_name != "edit" && (@page.nil? || section.subnav_children.include?(@page)) && last_row && !section.subnav_children.any?{|c| c.is_a?(Array)} && section.subnav_children.collect(&:to_s).join('').length > 120
      out = render("layouts/subnav", :section => section, :depth => depth, :last => bottom_normal_subnav && !overflow, :overflow => overflow)
      bottom_normal_subnav = false unless overflow
      last_row = false
    end
    render_subnav(section.parent, depth_to_show, last_row, bottom_normal_subnav) + out
  end
  
  def viewing_page?(page)
    return false if @page.nil? || !@page.is_a?(Page)
    page.is_a?(String) ? @page.permalink_name==page.gsub('/', '') : @page==page
  end
  
  def viewing_page_or_section?(page_or_section)
    page_or_section.is_a?(Page) ? viewing_page?(page_or_section) : current_section?(page_or_section)
  end
  
  def viewing_page_or_section_tree?(page_or_section)
    page_or_section.is_a?(Page) ? viewing_page?(page_or_section) : current_section_tree?(page_or_section)
  end
  
end
