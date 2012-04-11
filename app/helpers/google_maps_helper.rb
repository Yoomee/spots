module GoogleMapsHelper
  
  def google_map(objects, options ={})
    @map_index = options[:map_index] || ((@map_index || -1) + 1)
    @marker_names = [];
    objects = [*objects]
    options.reverse_merge!(
      :canvas_id => "map_canvas_#{map_index}",
      :width => 300,
      :height => 300,
      :map_type => "roadmap",
      :zoom => 6,
      :interactive => true,
      :draggable => false
    )
    options[:canvas_id] = "map_canvas_#{map_index}" #force it for now
    
    if !options[:centre]
      if objects.size == 1 && objects.first.has_lat_lng?
        options[:centre] = objects.first.lat_lng
      else
        options[:centre] = Location::DEFAULT_CENTER
      end
    end
    
    map_js = <<-JAVASCRIPT
      map#{map_index} = new google.maps.Map(document.getElementById('#{options[:canvas_id]}'),{
        zoom: #{options[:zoom]},
        center: new google.maps.LatLng(#{options[:centre].join(',')}),
        mapTypeId: google.maps.MapTypeId.#{options[:map_type].upcase},
        draggable:#{options[:draggable]}
        #{',disableDefaultUI:true,scrollwheel:false,disableDoubleClickZoom:true,keyboardShortcuts:false' if !options[:interactive]}
        #{',' + options[:map_options] unless options[:map_options].blank?}
      });
    JAVASCRIPT
    
    if options[:infoboxes]
      options[:infobox_options] = (options[:infobox_options] ||= {}).reverse_merge!({:offset => [0,0], :clearance => [10,10], :closebox_margin => "2px"})
      map_js << <<-JAVASCRIPT
        var infoBox = new InfoBox({
          pixelOffset: new google.maps.Size(#{options[:infobox_options][:offset].join(',')}),
          infoBoxClearance: new google.maps.Size(#{options[:infobox_options][:clearance].join(',')}),
          closeBoxMargin:'#{options[:infobox_options][:closebox_margin]}'
        });
      JAVASCRIPT
    end    
    if objects
      objects = objects.select(&:has_lat_lng?)
      options[:auto_bounds] = false if objects.size <= 1
      map_js <<   "var bounds = new google.maps.LatLngBounds();\n" if options[:auto_bounds]
      options[:marker_options] ||= {}
      objects.each_with_index do |object, index|
        map_js << marker(object, index, options[:marker_options])
        map_js << infobox(@marker_names.last, object) if options[:infoboxes]
        map_js << "bounds.extend(new google.maps.LatLng(#{object.lat},#{object.lng}));" if options[:auto_bounds]
      end
      map_js << "map#{map_index}.fitBounds(bounds);" if options[:auto_bounds]
    end
    map_js_tag = javascript_tag do 
      <<-JAVASCRIPT
      var map#{map_index};
      #{@marker_names.collect {|m| "var #{m};"}}
      $(document).ready(function() {
        #{map_js}
        #{options[:other]}
      });
      JAVASCRIPT
    end
    content_for :head do
      @included_google_maps_js ? map_js_tag : "#{header_tag(options)}#{map_js_tag}"
    end
    @included_google_maps_js = true
    options[:width] = "#{options[:width]}px" if options[:width].is_a?(Integer)
    options[:height] = "#{options[:height]}px" if options[:height].is_a?(Integer)
    content_tag(:div, "",:id => options[:canvas_id], :style => "width:#{options[:width]};height:#{options[:height]}#{options[:style].blank? ? '' : ";#{options[:style]}"}", :class => "map_canvas #{options[:class]}")
  end
  
  
  
  private
  
  def infobox(marker_name, object)
    infobox_method = "#{object.class.to_s.underscore}_infobox"
    content = send(infobox_method, object) if (methods.include?(infobox_method))
    content ||= object.to_s
    <<-JAVASCRIPT
  	google.maps.event.addListener(#{marker_name}, "click", function (e) {
  	  infoBox.setContent('#{escape_javascript(content)}')
  	  infoBox.open(map#{map_index}, this);
  	});
  	JAVASCRIPT
  end
  
  def map_index
    @map_index.zero? ? "" : @map_index
  end
  
  def marker(object, index, marker_options_hash = {})
    marker_options_hash ||= {}
    marker_options = "position: new google.maps.LatLng(#{object.lat},#{object.lng}),map: map#{map_index}, title:''"
    if marker_options_hash[:draggable]
      marker_options << ", draggable: true"
    end
    marker_image_method = "#{object.class.to_s.underscore}_marker_image"
    if (methods.include?(marker_image_method)) && (marker_image = send(marker_image_method, object))
      icon_string = (marker_image =~ /^new/) ? marker_image : "'#{marker_image}'" 
      marker_options << ", icon:#{icon_string}"
    end
    if object.new_record?
      marker_name = "marker#{object.class}New#{map_index}"
    else
      marker_name = "marker#{object.class}#{object.id}"
    end
    @marker_names << marker_name
    marker = "#{marker_name} = new google.maps.Marker({#{marker_options}});\n"
    #Marker dragend
    marker << "google.maps.event.addListener(#{marker_name}, 'dragend', #{marker_options_hash[:dragend]});\n" if marker_options_hash[:dragend]
    #Marker click
    marker_click_method = "#{object.class.to_s.underscore}_marker_click"
    puts marker_click_method
    if marker_options_hash[:click] && (methods.include?(marker_click_method)) && (marker_click = send(marker_click_method, object))
      marker << "google.maps.event.addListener(#{marker_name}, 'click', function() {#{marker_click}});"
    end
    marker
  end
  
  def header_tag(options = {})
    options.reverse_merge!(:sensor => false, :version => "3.3")
    api = content_tag("script", "", {:type => Mime::JS, :src => "http://maps.google.com/maps/api/js?v=#{options[:version]}&sensor=#{options[:sensor].to_s}"})
    "#{api}#{javascript_include_tag("infobox")}"
  end
  

end