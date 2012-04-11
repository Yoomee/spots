module TramlinesImages
  
  def self.included(klass)
    klass.cattr_accessor :image_attributes
    klass.image_attributes = klass.column_names.select {|col| col.match(/^.+_uid$/) && !col.match(/file_uid$/)}
    klass.image_attributes.each do |image_attr_uid|
      image_attr = image_attr_uid.chomp("_uid")
      if klass.respond_to?(:table_name)
        klass.send(:named_scope, "with_#{image_attr}", :conditions => "#{klass.table_name}.#{image_attr_uid} IS NOT NULL AND #{klass.table_name}.#{image_attr_uid} != ''")
      end
      klass.image_accessor(image_attr)
      klass.send(:define_method, "remove_#{image_attr}=") do |value|
        unless [0, "0", false, "false", "", nil].include?(value)
          dragonfly_attachments[image_attr].assign(nil)
          instance_variable_set("@remove_#{image_attr}", true)
        end
      end
      klass.send(:attr_reader,"remove_#{image_attr}")
      
      klass.send(:validates_property, :mime_type, :of => image_attr, :in => %w(image/jpeg image/png image/gif), :message => "must be an image")
    end
    klass.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def default_image(image_attr = 'image')
      Dragonfly::App[:images].fetch(default_image_location(image_attr))
    end

    def default_image_location(image_attr = 'image')
      default_filename = "#{self.to_s.underscore}_#{image_attr.to_s.chomp("_uid")}"
      File.exists?("#{RAILS_ROOT}/client/public/dragonfly/defaults/#{default_filename}") ? "client_defaults/#{default_filename}" : "defaults/#{default_filename}"
    end
    
  end
  
  def default_image(image_attr='image')
    self.class::default_image(image_attr)
  end
  
  def fetch_image_from_url(url)
    image_file = URLTempfile.new(url)
    image_file.size.zero? ? nil : image_file
  end
  
  def set_image_from_url(url,image_attr='image')
    if image_file = fetch_image_from_url(url)
      self.send("#{image_attr}=", image_file)
    end
  end
  
  def image_centre
    return "0.5,0.5" if !self.class::column_names.include?("image_centre") || read_attribute(:image_centre).blank?
    read_attribute(:image_centre)
  end
  
  def image_centre_x
    image_centre.split(",")[0]
  end
  
  def image_centre_y
    image_centre.split(",")[1]
  end
  
end