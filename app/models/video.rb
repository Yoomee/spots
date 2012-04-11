class Video < ActiveRecord::Base
  
  include Media
  include TramlinesImages
  include ValidateExtensions

  search_attributes %w{name description url}

  validates_presence_of :member, :url
  validates_url_format_of :url

  attr_accessor :invalid_url
  
  
  class << self
    
    def is_video_url?(url)
      [TextHelper::GOOGLE_VIDEO_URL_RE, TextHelper::VIMEO_URL_RE, TextHelper::YOUTUBE_URL_RE].any? {|reg| url.match(reg)}
    end
    
    def is_youtube_user_url?(url)
      url.match(TextHelper::YOUTUBE_USER_URL_RE)
    end
    
  end

  def is_video_url?
    return false if url.blank?
    self.class::is_video_url?(url)
  end
  
  def is_youtube_user_url?
    return false if url.blank?
    self.class::is_youtube_user_url?(url)
  end  

  def oembed_video
    if changed.include?('url')
      begin
        oembed = Embedit::Media.new(url)
        self.html = oembed.html
        self.image = open(oembed.thumbnail)
        self.name = oembed.title if read_attribute(:name).blank?
      rescue
        self.invalid_url = true
      end
    end
  end

  def reformatted_html options={}
    ret = self.html
    ret.gsub!(/\s+width="\d+"/, " width='#{options[:width]}' ") if options[:width]
    ret.gsub!(/\s+height="\d+"/, " height='#{options[:height]}' ") if options[:height]
    if options[:autoplay]
      unless ret.gsub!("fullscreen=1", "fullscreen=1&amp;autoplay=1")
        ret.gsub!(/http:[^"]*/, '\0?autoplay=1')
      end
    end
    ret.gsub!(/<\/object>/, "<param name='wmode' value='#{options[:wmode]}' /></object>") if options[:wmode]
    # Unencode
    CGI.unescapeHTML ret
  end

  def url=(value)
    value = 'http://' + value unless value.blank? || value =~ /^http/
    value = fix_youtube_link(value)
    write_attribute(:url, value)
    if is_video_url?
      oembed_video unless RAILS_ENV.to_sym == :test
    else
      self.invalid_url = true
    end
    value
  end

  def validate
    if !url.blank? && invalid_url
      self.errors.clear
      if is_youtube_user_url?
        self.errors.add(:url, "Please use the url for the video and not the channel.")
      else
        self.errors.add(:url, "Could not find video.")
      end
    else
      true
    end
  end

  private
  def fix_youtube_link(val)
    return val if val.blank?
    youtube_id = get_youtube_id(val)
    youtube_id.blank? ? val : "http://www.youtube.com/watch?v=#{youtube_id}"
  end

  def get_youtube_id(val)
    if res = val.match(TextHelper::YOUTUBE_URL_RE) || val.match(TextHelper::YOUTUBE_USER_ID_URL_RE)
      res[2]
    end
  end
    
end
