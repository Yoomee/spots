module HasLocation
  
  def self.included(klass)
    klass.has_one :location, :as => :attachable, :dependent => :destroy
    klass.accepts_nested_attributes_for :location, :allow_destroy => true
    klass.named_scope :with_lat_lng, :joins => :location, :conditions => "locations.lat IS NOT NULL AND locations.lat != '' AND locations.lng IS NOT NULL AND locations.lng != ''"
    klass.named_scope :nearest_to, lambda{|location|{:joins => :location, :select => "#{klass.table_name}.*,(#{Location::EARTH_RADIUS}*acos(cos(radians(#{location.lat||DEFAULT_CENTER[0]}))*cos(radians(locations.lat))*cos(radians(locations.lng)-radians(#{location.lng||DEFAULT_CENTER[1]}))+sin(radians(#{location.lat||DEFAULT_CENTER[0]}))*sin(radians(locations.lat))))AS distance",:order => "distance",:conditions => "locations.lat IS NOT NULL AND locations.lat != '' AND locations.lng IS NOT NULL AND locations.lat AND locations.lng != ''"}}
    klass.named_scope :within_distance_of, lambda{|location, distance|
      degree_diff = (distance.to_f/Location::MILES_PER_DEGREE)
      location = location.location unless location.is_a?(Location)
      condition_string = "locations.lat IS NOT NULL AND locations.lat != '' AND locations.lng IS NOT NULL AND locations.lat AND locations.lng != '' AND locations.lat BETWEEN :lat_min AND :lat_max AND locations.lng BETWEEN :lng_min AND :lng_max"
      condition_string.prepend("locations.id != :location_id AND ") if location.id
      {
        :joins => :location,
        :conditions => [
          condition_string,
          {:location_id => location.id, :lat_min => location.lat.to_f - degree_diff, :lat_max => location.lat.to_f + degree_diff, :lng_min => location.lng.to_f - degree_diff, :lng_max => location.lng.to_f + degree_diff}
        ]
      }
    }
    klass.send(:define_method, :location_with_initial_build) do
      @location ||= (location_without_initial_build || build_location)
    end
    klass.alias_method_chain :location, :initial_build
    klass.delegate :lat_lng, :lat, :lat=, :lng, :lng=, :address1, :address1=, :address2, :address2=, :city, :city=, :country, :country=, :map, :postcode, :postcode=, :map_div, :has_lat_lng?, :address_string, :to => :location
    klass.after_save :save_location
  end
  
  def distance_to(other_location)
    location.distance_to(other_location)
  end

  def has_location?
    !location.new_record?
  end
  alias_method :has_address?, :has_location?

  # TODO: may not be needed
  def save_location
    location.attachable = self
    location.save!
  end
  
end
