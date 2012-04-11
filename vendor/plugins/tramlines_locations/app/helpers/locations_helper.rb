module LocationsHelper
  
  def gmaps_api_key
    env = ENV['RAILS_ENV'] || RAILS_ENV  
    YAML.load_file(RAILS_ROOT + '/config/gmaps_api_key.yml')[env]
  end

  def render_address(location, options = {})
    if location.nil?
      if !(options[:multi_line] && options[:append_missing_lines])
        return '' 
      else
        # Continue with blank location
        location = Location.new
      end
    end
    return "" if location.nil?
    location = location.location if !location.is_a?(Location) && location.respond_to?(:location)
    options.reverse_merge!(:html => true, :multi_line => false, :country => (location.country != "United Kingdom"))
    if options[:multi_line]
      separator = options[:separator] || (options[:html] ? "<br />" : "\n")
    else
      separator = ", "
    end
    out = ""
    out << (location.address1 + separator) unless location.address1.blank?
    out << (location.address2 + separator) unless location.address2.blank?    
    out << (location.city + separator) unless location.city.blank?
    out << (location.country + separator) if options[:country] && !location.country.blank?
    out << location.postcode unless location.postcode.blank?
    return "" if out.blank? && !(options[:multi_line] && options[:append_missing_lines])
    out.sub!(/#{separator}$/, '')
    if options[:multi_line] && options[:append_missing_lines]
      # Add blank lines for missing address fields
      lines = out.scan(separator).size
      out << (separator * (5 - lines))
    end
    options[:html] ? content_tag(:p, out, :class => "contact_address") : out
  end
  
  def render_google_map(location, options = {})
    options.reverse_merge!(:width => 300, :height => 300)
    return "" if !location.has_lat_lng?
    content_for(:head) {GMap.header(:host => request.host, :version => 2) + location.map.to_html}
    location.map_div(:width => options[:width], :height => options[:height])
  end
  alias_method :render_google_map_for, :render_google_map
  
end