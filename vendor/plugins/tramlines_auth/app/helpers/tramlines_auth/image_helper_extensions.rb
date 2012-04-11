module TramlinesAuth::ImageHelperExtensions

  def self.included(klass)
    klass.alias_method_chain(:image_for, :facebook)
  end
  
  def image_for_with_facebook(object, img_options = [], options = {})
    if object.is_a?(Member) && !object.has_image? && object.fb_connected?
      width, height = get_img_size_options(img_options)
      options[:width] ||= width
      options[:height] ||= height
      facebook_image_for(object, options.merge(options.delete(:fb) || {}))
    else
      options.delete(:fb)
      image_for_without_facebook(object, img_options, options)
    end
  end
  
end