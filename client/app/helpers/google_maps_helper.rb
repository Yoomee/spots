GoogleMapsHelper.module_eval do
  
  def google_map_with_spots(objects, options ={})
    options.reverse_merge!(:version => "3.5")
    options[:map_options] = options[:map_options].to_s + "scrollwheel:false,streetViewControl:false,zoomControl:true,zoomControlOptions:{style:google.maps.ZoomControlStyle.SMALL},minZoom:2"
    google_map_without_spots(objects, options)
  end    
  alias_method_chain :google_map, :spots
  
end