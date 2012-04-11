module ImageHelper
  
  class << self
    def download_image_url_prefix
      if @download_image_url_prefix.nil?
        prod_site_url = (APP_CONFIG["production"].try(:[], "site_url") || APP_CONFIG[:site_url])
        prod_site_url.chomp!("/")
        http_auth = [APP_CONFIG[:http_basic_username],APP_CONFIG[:http_basic_password]].join(':')
        prod_site_url.sub!(%r{^http://}, "http://#{http_auth}@") if http_auth != ':'
        @download_image_url_prefix = prod_site_url
      else
        @download_image_url_prefix
      end
    end
  end
  
  def default_image_for(object, img_size = nil, options = {})
    method = options.delete(:method) || :image
    image = object.default_image(method)
    dragonfly_image_tag(image, options.merge(:img_size => img_size))
  end
  
  def dragonfly_image_tag(image, options = {})
    if image.nil?
      options[:url_only] ? "" : image_tag("", options)
    else
      img_size = options.delete(:img_size) || APP_CONFIG[:photo_resize_geometry]
      image = image.process(:thumb, img_size)
      image = image.encode(options.delete(:extension)) if !options[:extension].blank?
      image_url = options.delete(:host).to_s + image.url
      return image_url if options[:url_only]
      image_tag(image_url, options)
    end
  end
  
  def get_img_size_options(size_string)
    size_string = size_string.is_a?(Array) ? size_string.first : size_string
    res = size_string.blank? ? nil : size_string.match(/(\d+)x?(\d*)/)
    res ? [res[1], res[2]] : [nil, nil]
  end
  
  def holding_image(img_size, options = {})
    options.merge!(:img_size => img_size)
    dragonfly_image_tag(Dragonfly::App[:images].fetch("defaults/holding"), options)
  end
  
  def text_as_image(text, options={})
    options.reverse_merge!(
      :background_color => '#FFFFFF',
      :color => '#000000',
      :encode => 'hex',
      :font => 'Helvetica',
      :font_size => 14,
      :class => 'text_as_image'
    )
    color = options.delete(:color)
    app = Dragonfly[:images]
    image = app.generate(:text, text,
      :font_size => options.delete(:font_size),
      :font_family => options.delete(:font),
      :stroke_color => color,
      :color => color,
      :font_stretch => 'expanded',
      :background_color => options.delete(:background_color),
      :format => :png                
    )
    image_tag(image.url, options)
  end
  
  # e.g image_for(@member, '100x100', :extension => 'png', :class => 'image')
  def image_for(object, img_size = nil, options = {})
    return options[:url_only] ? "" : image_tag("", options) if object.nil?
    crop_name = options.delete(:crop_name).presence || "image_centre"
    method = options.delete(:method) || :image
    assoc = object.class.reflect_on_association(method.to_sym)
    crop_coord = nil
    if !assoc.nil? && assoc.klass == Photo
      photo = object.send(method)
      if photo.nil?
        if options[:placeholder]
          width,height = get_img_size_options(img_size)
          return image_placeholder(width,height,options)
        else
          image = Photo.default_image
        end
      else
        crop_coord = photo.send(crop_name) if photo.respond_to?(crop_name)
        image = photo.image
      end
    elsif object.has_image?(method)
      image = object.send(method)
    elsif options[:placeholder]
      width,height = get_img_size_options(img_size)
      return image_placeholder(width,height,options)
    else
      image = object.default_image(method)
    end
    fetch_image_if_missing(image) if Rails.env == 'development'
    width, height = get_img_size_options(img_size)
    if img_size && img_size.is_a?(String) && img_size.ends_with?("#") && (crop_coord || object.respond_to?(crop_name))
      crop_coord ||= object.send(crop_name) if object.respond_to?(crop_name)
      img_size << crop_coord unless crop_coord == '0.5,0.5'
    end
    options.reverse_merge!(:alt => "#{(object.to_s || "")[0..(width || 50).to_i / 6]}...")
    options.reverse_merge!(:title => (object.to_s || ""))
    dragonfly_image_tag(image, options.merge(:img_size => img_size))
  end
  
  def image_or_photo_for(object, img_options = [], options = {})
    method = %w{image photo}.detect do |meth|
      object.respond_to?(meth) # && !object.send(meth).blank?
    end
    if method
      options.merge!(:method => method)
      image_for(object, img_options, options)
    else
      ''
    end
  end
  
  def image_placeholder(width,height,options={})
    image_url = "http://placehold.it/#{[width,height].compact.join('x')}"
    options[:image_url] ? "" : image_tag(image_url,options)
  end
  
  
  def photo_for(object, img_options = [], options = {})
    options.reverse_merge!(:method => :photo)
    image_for(object, img_options, options)
  end
  alias_method :photo_or_default_for, :photo_for
  
  private
  def fetch_image_if_missing(image)
    begin
      image.path
    rescue Dragonfly::DataStorage::DataNotFound => e
      image_url = "#{ImageHelper::download_image_url_prefix}#{image.url}"
      image_path = e.message.match(/\s([^\s]*)$/).try(:[],1)
      if !image_url.blank? && !image_path.blank?
        growl
        system("mkdir -p #{image_path.sub(/[^\/]*$/, "")}")
        puts "Downloading image: #{image_url}."
        system("curl -sf #{image_url} -o #{image_path}")
      end
    end
  end
  
  def growl
    if !@growled
      system("growlnotify -t 'Script/Server' -m 'Downloading missing image(s)'")
      @growled = true
    end
  end
  
end
