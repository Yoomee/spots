require 'iso_3116'
class Location < ActiveRecord::Base

  DEFAULT_LAT = "51.5"
  DEFAULT_LNG = "-0.116667"
  DEFAULT_CENTER = [DEFAULT_LAT, DEFAULT_LNG]
  DEFAULT_ZOOM = 10
  
  RADIAN_PER_DEGREE = Math::PI / 180.0
  Location::EARTH_RADIUS = 3963.19
  Location::MILES_PER_DEGREE = 69.16

  belongs_to :attachable, :polymorphic => true

  before_save :get_lat_lng

  delegate :div, :to => :map, :prefix => true

  attr_boolean_accessor :skip_geocode_lat_lng
  
  class << self

    def from_ip_address(ip_address)
      return nil if !ip_address =~ /^(\d{1,3}\.){3}\d{1,3}$/
      if (res = Geokit::Geocoders::MultiGeocoder.geocode(ip_address)).success
        new(:lat => res.lat, :lng => res.lng, :city => res.city, :country_code => res.country_code)
      end
    end

  end

  def address_changed?
    %w{address1 address2 city postcode}.any? {|attribute| attribute.in?(changed)}
  end

  def address_string
    field_vals = %w{address1 address2 city postcode country}.map {|field| send(field)}
    field_vals.reject(&:blank?).join ', '
  end

  def address_string_with_uk
    country.blank? ? address_string << ", UK" : address_string
  end
  
  def country_code
    ISO3116::name_to_code(country.upcase)
  end
  
  def country_code=(val)
    return true if !country.blank?
    self.country = ISO3116::code_to_name(val.upcase).try(:titleize)
  end

  #in miles
  def distance_to(other_location)
    return nil if !has_lat_lng? || !other_location.has_lat_lng?
    lat1_radians = lat.to_f * RADIAN_PER_DEGREE
    lat2_radians = other_location.lat.to_f * RADIAN_PER_DEGREE

    distance_lat = (other_location.lat.to_f - lat.to_f) * RADIAN_PER_DEGREE
    distance_lng = (other_location.lng.to_f - lng.to_f) * RADIAN_PER_DEGREE

    a = Math.sin(distance_lat/2)**2 + Math.cos(lat1_radians) * Math.cos(lat2_radians) * Math.sin(distance_lng/2) ** 2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    Location::EARTH_RADIUS * c
  end
  
  def geocode_lat_lng
    if !address_string.blank?
      address_to_search = address_string_with_uk
    	until lat_lng = GoogleGeocode::get_lat_lng(address_to_search)
        break if address_to_search=="UK"
        address_parts = address_to_search.split(", ")
        address_parts.pop(2)
        address_to_search = address_parts.empty? ? "UK" : address_parts.join(", ") + ", UK"
    	end
      self.lat, self.lng = lat_lng.collect(&:to_s) if lat_lng
    end
  end
  
  def has_lat_lng?
    !lat.blank? && !lng.blank?
  end

  def lat_lng
    has_lat_lng? ? [lat, lng] : nil
  end

  def location
    self
  end
  
  def map(options = {})
    return @map if @map
    @map = GMap.new("location_map_#{id}")
    if has_lat_lng?
      @map.center_zoom_init(lat_lng, DEFAULT_ZOOM)
    else
      @map.center_zoom_init(DEFAULT_CENTER, DEFAULT_ZOOM)
    end
    @map.control_init(:small_map => true)
    if has_lat_lng?
      @map.declare_init(map_marker(options[:draggable]), 'marker')
      @map.overlay_init(Variable.new('marker'))
      if options[:dragend]
        @map.event_init(Variable.new('marker'), 'dragend', options[:dragend])
      end
    end
    @map
  end

  def map_marker(draggable = false)
    marker = GMarker.new(lat_lng, :draggable => draggable)
    marker.enable_dragging if draggable
    marker
  end
  
  def reverse_geocode 
    if has_lat_lng?
      if (city_country = GoogleGeocode::get_address(lat_lng))
        self.city, self.country = city_country
      end
    end
  end
  
  def unknown?
    address1.blank? && address2.blank? && city.blank? && country.blank? && postcode.blank? && lat.blank? && lng.blank?
  end

  private
  def get_lat_lng
    if !skip_geocode_lat_lng? && (!has_lat_lng? || (!new_record? && address_changed?))
      geocode_lat_lng
    end
    true
  end

end
