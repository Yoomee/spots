require 'net/http'
require 'net/https'

class ShortUrl < ActiveRecord::Base
  validates_presence_of :long, :short
  validates_uniqueness_of :long, :short
  
  before_validation :resolve
  
  class << self
    def shorten(long_url)
      find_or_create_by_long(long_url).short
    end      
      
    def expand(short_url)
      find_or_create_by_short(short_url).long
    end
    alias_method :lengthen, :expand
  end
  
  def code
    short.split('/').last
  end
  
  def info
    http = Net::HTTP.new('www.googleapis.com', 443)
    http.use_ssl = true
    path = "/urlshortener/v1/url?shortUrl=#{short}&projection=FULL&key=#{APP_CONFIG['google_url_shortener_api_key']}"
    begin
      resp, data = http.get(path)
      resp.value #Raises error if response error is not 2xx
      JSON.parse(data)
    rescue
      false
    end
  end
  
  def info_url
    "http://goo.gl/info/#{code}"
  end
  
  def clicks
    info["analytics"]["allTime"]["shortUrlClicks"].to_i
  end
  
  private
  
  def resolve
    if long.blank? && !short.blank?
      puts "Getting long"
      get_long
    elsif short.blank? && !long.blank?
      puts "Getting short"
      generate_short
    end
  end
  
  def get_long
    http = Net::HTTP.new('www.googleapis.com', 443)
    http.use_ssl = true
    path = "/urlshortener/v1/url?shortUrl=#{short}&key=#{APP_CONFIG['google_url_shortener_api_key']}"
    begin
      resp, data = http.get(path)
      resp.value #Raises error if response error is not 2xx
      self.long = JSON.parse(data)["longUrl"]
    rescue
      false
    end
  end
  
  def generate_short
    http = Net::HTTP.new('www.googleapis.com', 443)
    http.use_ssl = true
    path = "/urlshortener/v1/url?key=#{APP_CONFIG['google_url_shortener_api_key']}"
    data = "{'longUrl': '#{long}'}"
    headers = {'Content-Type'=> 'application/json'}
    # Disabled as needs to be fetched every time
    # headers['Authorization'] = "GoogleLogin auth=#{APP_CONFIG['google_client_login']}" unless RAILS_ENV == "development"
    begin
      resp, data = http.post(path, data, headers)
      resp.value #Raises error if response error is not 2xx
      self.short = JSON.parse(data)["id"]
    rescue
      false
    end
  end
end
