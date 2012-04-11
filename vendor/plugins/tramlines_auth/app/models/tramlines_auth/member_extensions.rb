require 'net/http'
require 'net/https' if RUBY_VERSION < '1.9'
require 'uri'

begin
  require 'linkedin'
rescue LoadError
  puts "no such file to load -- linkedin"
  puts "add config.gem linkedin to enable LinkedIn support."
end

module TramlinesAuth::MemberExtensions
  
  def self.included(klass)
    klass.extend ClassMethods
    klass.before_validation_on_create :fetch_twitter_image
    klass.before_validation_on_create :fetch_linked_in_image
    klass.before_validation_on_create :get_linked_in_profile_url
    klass.send :attr_accessor, :auth_service
    klass.send :attr_accessor, :linked_in_image_url
    klass.alias_method_chain(:force_password_change?, :auth)
  end
  
  module ClassMethods
  
    def find_or_initialize_with_facebook(facebook_user)
      if member = Member.find_by_fb_user_id(facebook_user.id)
        return member
      elsif !facebook_user.email.blank? && member = Member.find_by_email(facebook_user.email)
        member.fb_user_id = facebook_user.id
        return member
      else
        Member.new_facebook(facebook_user)
      end
    end
    
    def find_or_initialize_with_linked_in(auth)
      if member = Member.find_by_linked_in_user_id(auth['uid'])
        member.linked_in_token = auth['credentials']['token']
        member.linked_in_secret = auth['credentials']['secret']
        member.send(:get_linked_in_profile_url) if member.linked_in_profile_url.blank?
        return member
      else
        user_info = HashWithIndifferentAccess.new(auth['user_info'])
        user_info[:linked_in_user_id] = auth['uid']
        user_info[:linked_in_token] = auth['credentials']['token']
        user_info[:linked_in_secret] = auth['credentials']['secret']
        Member.new_linked_in(user_info)
      end
    end
  
    def find_or_initialize_with_omniauth(auth)
      case auth["provider"]
      when "twitter"
        find_or_initialize_with_twitter(auth)
      when 'linked_in'
        find_or_initialize_with_linked_in(auth)
      end
    end
  
    def find_or_initialize_with_twitter(auth)
      if member = Member.find_by_twitter_id(auth["uid"])
        member.twitter_token = auth['credentials']['token']
        member.twitter_secret = auth['credentials']['secret']
        return member
      else
        user_info = HashWithIndifferentAccess.new(auth["user_info"])
        user_info[:twitter_id] = auth['uid']
        user_info[:twitter_token] = auth['credentials']['token']
        user_info[:twitter_secret] = auth['credentials']['secret']
        Member.new_twitter(user_info)
      end
    end
    
    protected
    def new_facebook(facebook_user)
      attributes = {:email => facebook_user.email, :fb_user_id => facebook_user.id, :forename => facebook_user.first_name, :surname => facebook_user.last_name}
      new(attributes)
    end
    
    def new_linked_in(attributes)
      attributes[:full_name] = attributes.delete(:name)
      attributes[:linked_in_location] = attributes.delete(:location)
      attributes[:urls] = attributes[:urls].collect{|k,v| Url.new(:url => v)}
      attributes[:surname] = attributes.delete(:last_name)
      attributes[:bio] = attributes.delete(:description)
      attributes[:forename] = attributes.delete(:first_name)
      attributes.delete(:full_name)
      attributes[:linked_in_image_url] = attributes.delete(:image)
      attributes[:auth_service] = 'LinkedIn'
      new(attributes)
    end

    def new_twitter(attributes)
      attributes[:full_name] = attributes.delete(:name)
      # Location is a bit generic in Twitter
      attributes.delete(:location)
      attributes[:urls] = attributes[:urls].collect{|k,v| Url.new(:url => v)}
      nickname = attributes.delete(:nickname)
      attributes[:username] = Member.generate_valid_username(nickname)
      attributes[:twitter_username] = nickname
      attributes[:bio] = attributes.delete(:description)
      attributes[:auth_service] = 'Twitter'
      new(attributes)
    end
  
  end
  
  def add_auth_from_session(auth_data)
    puts auth_data.inspect
    case auth_data[:auth_service]
    when 'Facebook'
      self.update_attributes(:fb_user_id => auth_data[:auth_id]) unless !fb_user_id.blank?
    when 'Twitter'
      self.update_attributes(:twitter_id => auth_data[:auth_id], :twitter_username => auth_data[:auth_username], :twitter_token => auth_data[:auth_token], :twitter_secret => auth_data[:auth_secret]) unless !twitter_id.blank?
    when 'LinkedIn'
      self.update_attributes(:linked_in_user_id => auth_data[:auth_id], :linked_in_token => auth_data[:auth_token], :linked_in_secret => auth_data[:auth_secret]) unless !linked_in_user_id.blank?
    end
  end
  
  def add_omniauth(auth)
    case auth["provider"]
    when "twitter"
      self.twitter_id = auth['uid'] if twitter_id.blank?
      self.twitter_username = auth['user_info']['nickname'] if twitter_username.blank?
      self.twitter_token = auth['credentials']['token']
      self.twitter_secret = auth['credentials']['secret']
    when 'linked_in'
      self.linked_in_user_id ||= auth['uid'] if linked_in_user_id.blank?
    end
  end
  
  def auth_connected?
    facebook_connected? || twitter_connected? || linked_in_connected?
  end
  
  def facebook_connected?
    !fb_user_id.blank?
  end
  
  def fb_profile_url
    fb_connected? ? "http://www.facebook.com/profile.php?id=#{fb_user_id}" : ""
  end
  
  def force_password_change_with_auth?
    return false if twitter_connected? || linked_in_connected? || facebook_connected?
    force_password_change_without_auth?
  end
  
  def linked_in_connected?
    !linked_in_user_id.blank?
  end

  def linked_in_location=(place)
    place_arr = place.split(/[,\s*]/).reverse
    self.location_attributes = {:country => place_arr[0], :city => place_arr[1]}
  end
  
  def twitter_connected?
    !twitter_id.blank?
  end
  
  def twitter_profile_url
    twitter_username.blank? ? "" : "http://www.twitter.com/#{twitter_username}"
  end

  private
  def fetch_linked_in_image
    return true if linked_in_image_url.blank? || !image.blank?
    self.image = fetch_image_from_url(linked_in_image_url)
  end
  
  def fetch_twitter_image
    return true if twitter_username.blank? || !image.blank?
    self.image = fetch_image_from_url(twitter_image_url)
  end
  
  def get_linked_in_profile_url
    return true if linked_in_token.blank? || linked_in_secret.blank? || !linked_in_profile_url.blank?
    client = LinkedIn::Client.new(LINKED_IN_KEY, LINKED_IN_SECRET)
    client.authorize_from_access(linked_in_token, linked_in_secret)
    begin
      profile = client.profile(:public => true)
      self.linked_in_profile_url = profile.try(:public_profile_url)
    rescue LinkedIn::NotFound
      # Unable to get public profile
    end
  end

  def twitter_image_url
    u = URI.parse("http://api.twitter.com/1/users/profile_image/#{twitter_username}.json")
    h = Net::HTTP.new u.host, u.port
    h.use_ssl = u.scheme == 'https'
    head = h.start do |ua|
      ua.head "#{u.path}?size=original"
    end
    head['location']
  end
  
end
