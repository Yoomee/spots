class GoogleGeocode 
  
  def self.get_lat_lng(address)
    url = "http://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode(address)}&sensor=false"
    begin
      res = open(url)
    rescue Exception => e
      return nil
    end
    return nil if res.status[0] != "200"
    data = JSON.parse(res.read)
    return nil if data["status"] != "OK"
    location = data["results"][0]["geometry"]["location"]
    return [location["lat"], location["lng"]]
  end
  
  def self.get_address(lat_lng, options = {})
    url = "http://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat_lng.join(',')}&sensor=false"  
    begin
      res = open(url)
    rescue Exception => e
      return nil
    end
    return nil if res.status[0] != "200"
    data = JSON.parse(res.read)
    return nil if data["results"].blank? || (address_components = data["results"][0]["address_components"]).nil?
    city = address_components.select{|c| c["types"].include?("locality")}.try(:first).try(:[], "long_name")
    city = address_components.select{|c| c["types"].include?("administrative_area_level_3")}.try(:first).try(:[], "long_name") if city.nil?
    city = address_components.select{|c| c["types"].include?("administrative_area_level_2")}.try(:first).try(:[], "long_name") if city.nil?
    city = address_components.select{|c| c["types"].include?("administrative_area_level_1")}.try(:first).try(:[], "long_name") if city.nil?
    country = address_components.select{|c| c["types"].include?("country")}.try(:first).try(:[], "long_name")
    return city, country
  end
end