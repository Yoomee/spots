module SectionsHelper
  
  # Month and years should be an array of month-number, year-number pairs
  def month_and_year_option_tags month_and_years, selected_month = nil, selected_year = nil
    month_and_years.inject('') do |ret, month_and_year|
      month = month_and_year[0]
      year = month_and_year[1]
      ret += "<option value='#{year}/#{month}'"
      ret += " selected='selected'" if year == selected_year && month == selected_month
      ret += ">#{Date::MONTHNAMES[month]} #{year}</option>"
    end
  end
  
  def possible_parent_sections?(section = nil)
    !(Section.all - [section]).empty?
  end
  
  def possible_parent_section_option_tags(current_section)
    "<option></option>" + section_option_tags(current_section.parent, Section.root, current_section)
  end

  def section_option_tags(selected = nil, sections = Section.root, current_section = nil, indent_level = 0)
    selected = selected.section if selected.is_a?(Page)
    (sections - [current_section]).inject('') do |memo, section|
      ret = "<option value='#{section.id}'"
      ret << " selected='selected'" if section == selected
      ret << ">#{'&nbsp;&nbsp;&nbsp;' * indent_level}#{section}</option>"
      unless section.children.empty?
        ret << section_option_tags(selected, section.children, current_section, indent_level + 1)
      end
      memo + ret
    end
  end
    
    
end