#require 'dragonfly'
require 'dragonfly/rails/images'

# Modified version of Rack middleware to allow dragonfly 0.8.2 to run on passenger
module Dragonfly
  class Middleware

    def initialize(app, dragonfly_app_name, deprecated_arg)
      @app = app
      @dragonfly_app_name = dragonfly_app_name
    end

    def call(env)
      path_info = env['PATH_INFO'] || env['REQUEST_URI']
      response = Dragonfly[@dragonfly_app_name].call(env)
      if route_not_found?(response) || !(path_info =~ /\w+/) || (path_info =~ /^\/\?/)
        @app.call(env)
      else
        response
      end
    end

    private
    def route_not_found?(response)
      response[1]['X-Cascade'] == 'pass' ||
        (rack_version_doesnt_support_x_cascade? && response[0] == 404)
    end

    def rack_version_doesnt_support_x_cascade?
      Rack.version < '1.1'
    end
  end
end

module Dragonfly
  module Processing
    class RMagickProcessor

      CROPPED_RESIZE_CENTRE_GEOMETRY = /^(\d+)x(\d+)#([01]\.\d+),([01]\.\d+)$/ # e.g. '20x50#0.5,0.5'
      
      def resize_and_crop_centre(temp_object, opts={})
        rmagick_image(temp_object) do |image|
          width   = opts[:width] ? opts[:width].to_i : image.columns
          height  = opts[:height] ? opts[:height].to_i : image.rows
          
          width_scale_factor  = image.columns.to_f/width
          height_scale_factor = image.rows.to_f/height
          
          if width_scale_factor > height_scale_factor
            # Width will change more => will want to crop width => force height to desired final height
            geom = "x#{height}"
            y = 0
            x = ((image.columns/height_scale_factor) * opts[:centre][0]) - (width.to_f/2)
            if x < 0
              x = 0
            elsif x > image.columns/height_scale_factor
              x = (image.columns/height_scale_factor) - width
            end
          else
            # Height will change more => will want to crop height => force width to desired final width
            geom = "#{width}x"
            x = 0
            y = ((image.rows/width_scale_factor) * opts[:centre][1]) - (height.to_f/2)
            if y < 0
              y = 0
            elsif y > image.rows/width_scale_factor
              y = (image.rows/width_scale_factor) - height
            end
          end
          
          resized_temp_object = Dragonfly::TempObject.new(resize(temp_object, geom))

          crop_options = {
            :x => x.to_i,
            :y => y.to_i,
            :width => width,
            :height => height,
            :gravity => Magick::NorthWestGravity
          }
          
          crop(resized_temp_object,crop_options)
        end
      end

      def thumb_with_centre(temp_object, geometry)
        if geometry.match(CROPPED_RESIZE_CENTRE_GEOMETRY)
          resize_and_crop_centre(temp_object, :width => $1, :height => $2, :centre => [$3.to_f, $4.to_f])
        else
          thumb_without_centre(temp_object, geometry)
        end
      end
      alias_method_chain :thumb, :centre
      
    end
  end
end

middleware = Rails.respond_to?(:application) ? Rails.application.middleware : ActionController::Dispatcher.middleware

app = Dragonfly::App[:attachments]
app.configure_with(Dragonfly::Config::RMagick, :use_filesystem => false)
app.configure_with(Dragonfly::Config::Rails) do |c|
  c.analyser.register(Dragonfly::Analysis::FileCommandAnalyser) do |a|
    a.use_filesystem = false
  end
  c.encoder.register(Dragonfly::Encoding::RMagickEncoder) do |e|
    e.use_filesystem = false
  end
  c.log Rails.logger
  c.url_path_prefix = '/uploads'
  c.datastore.configure do |d|
    d.root_path = "#{RAILS_ROOT}/uploads" if c.datastore.is_a?(Dragonfly::DataStorage::FileDataStore)
  end
end

app.content_filename = proc{|job, request|
  if job.basename
    extname = job.encoded_extname || (".#{job.ext}" if job.ext) || (".#{job.format.to_s}" if job.format)
    "#{job.basename}#{extname}"
  end
}

app.content_disposition = :attachment


middleware.insert_after Rack::Lock, Dragonfly::Middleware, :attachments, app.url_path_prefix

# Dragonfly::Config::Rails.module_eval do
# 
#   class << self
# 
#     def apply_configuration_with_tramlines(app)
#       apply_configuration_without_tramlines(app)
#       app.configure do |c|
#         c.register_analyser(Dragonfly::Analysis::FileCommandAnalyser)
#         c.register_encoder(Dragonfly::Encoding::TransparentEncoder)
#         c.datastore.configure do |d|
#           d.root_path = "#{RAILS_ROOT}/uploads" if c.datastore.is_a?(Dragonfly::DataStorage::FileDataStore)
#         end
#       end
#     end
#     alias_method_chain :apply_configuration, :tramlines
#     
#   end
#   
# end

# Dragonfly.active_record_macro(:attachment, app)
app.define_macro(ActiveRecord::Base, :attachment_accessor)

# Set up and configure the dragonfly app
app = Dragonfly::App[:images]




# app.configure_with(Dragonfly::Config::RMagickImages)
app.configure_with(Dragonfly::Config::RMagick, :use_filesystem => false)
#app.configure_with(Dragonfly::Config::Rails) do |c|
app.configure do |c|
  c.log = Rails.logger
  c.datastore.configure do |d|
    d.root_path = "#{RAILS_ROOT}/public/dragonfly" if c.datastore.is_a?(Dragonfly::DataStorage::FileDataStore)
  end
  # c.url_handler.configure do |u|
  #   # u.secret = 'insert some secret here to protect from DOS attacks!'
  #   u.path_prefix = '/media'
  # end
  c.url_path_prefix = '/media'
end

middleware.insert_after Rack::Lock, Dragonfly::Middleware, :images, app.url_path_prefix

middleware.insert_before 'Dragonfly::Middleware', 'Rack::Cache', {
  :verbose     => true,
  :metastore   => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/meta"), # URI encoded because Windows
  :entitystore => URI.encode("file:#{Rails.root}/tmp/dragonfly/cache/body")  # has problems with spaces
}

module Dragonfly
  module DataStorage
    class FileDataStore
      
      # used in purge_empty_directories. An error is thrown when deleting a document when it is the last one left in the uploads/2011 directory
      # so we don't want dragonfly to rm the '2011' directory even if it is empty
      private
      def directory_empty_with_year_directory_check?(path)
        if path.match(/uploads\/\d{4}$/)
          false
        else
          directory_empty_without_year_directory_check?(path)
        end
      end
      alias_method_chain :directory_empty?, :year_directory_check
      
    end 
  end
end

Dragonfly::TempObject.class_eval do
=begin
  def tempfile
    @tempfile ||= begin
      case initialized_with
      when :tempfile
        @tempfile = initialized_tempfile
        @tempfile.close!
      when :data
        @tempfile = new_tempfile(initialized_data)
      when :file
        @tempfile = copy_to_tempfile(initialized_file.path)
      end
      @tempfile
    end
  end
=end


=begin
  # This almost worked!!!
  def file(&block)
    f = tempfile.open
    tempfile.binmode
    if block_given?
      ret = yield f
      tempfile.close!
    else
      ret = f
    end
    ret
  end
=end

=begin 
  def new_tempfile(content=nil)
    tempfile = Tempfile.new('dragonfly')
    tempfile.binmode
    tempfile.write(content) if content
    tempfile.close!
    tempfile
  end
=end
  
end
# 
# Dragonfly::RMagickUtils.class_eval do
#   
#   private
#   def write_to_tempfile(rmagick_image)
#     tempfile = Tempfile.new('dragonfly')
#     tempfile.close!
#     rmagick_image.write(tempfile.path)
#     tempfile
#   end
# 
# end
# 
# Dragonfly::ImageMagickUtils.class_eval do
#   
#   private
#   def new_tempfile(ext=nil)
#     tempfile = ext ? Tempfile.new(['dragonfly', ".#{ext}"]) : Tempfile.new('dragonfly')
#     tempfile.binmode
#     tempfile.close!
#     tempfile
#   end
#   
# end

# Dragonfly::DataStorage::FileDataStore.class_eval do
#   
#   def store(temp_object, opts={})
#     relative_path = if opts[:path]
#       opts[:path]
#     else
#       filename = temp_object.name || 'file'
#       relative_path = relative_path_for(filename)
#     end
# 
#     begin
#       path = absolute(relative_path)
#       until !File.exist?(path)
#         path = disambiguate(path)
#       end
#       prepare_path(path)
#       temp_object.to_file(path).close!
#       store_extra_data(path, temp_object)
#     rescue Errno::EACCES => e
#       raise UnableToStore, e.message
#     end
# 
#     relative(path)
#   end
#   
#   
#   
# end

# Dragonfly.active_record_macro(:image, app)

# Extend ActiveRecord
# This allows you to use e.g.
#   image_accessor :my_attribute
# in your models.
# ActiveRecord::Base.extend Dragonfly::ActiveRecordExtensions
# ActiveRecord::Base.register_dragonfly_app(:image, Dragonfly::App[:images])


# middleware.insert_after Rack::Lock, Dragonfly::Middleware, :images
# middleware.insert_after Rack::Lock, Dragonfly::Middleware, :attachments

# # UNCOMMENT THIS IF YOU WANT TO CACHE REQUESTS WITH Rack::Cache
# require 'rack/cache'
# middleware.insert_before Dragonfly::Middleware, Rack::Cache, {
#    :verbose     => true,
#    :metastore   => "file:#{Rails.root}/tmp/dragonfly/cache/meta",
#    :entitystore => "file:#{Rails.root}/tmp/dragonfly/cache/body"
# }

# Modify destroy_attachments to prevent it deleting default images
# Modify save_attachments to prevent it copying default images

# module Dragonfly::ActiveRecordExtensions::InstanceMethods
# module Dragonfly::ActiveModelExtensions::InstanceMethods
#   
#   def destroy_attachments
#     attachments.each do |attribute, attachment|
#       attachment.destroy! unless read_attribute("#{attribute}_uid").blank?
#     end
#   end
#   
#   def save_attachments
#     attachments.each do |attribute, attachment|
#       attachment.save! unless read_attribute("#{attribute}_uid").blank?
#     end
#   end
#   
# end

# When an attachment is saved, its previous_uid is destroyed
# We do not want this to happen if its previous_uid is a default image (e.g. link_image)
# class Dragonfly::ActiveRecordExtensions::Attachment
# class Dragonfly::ActiveModelExtensions::Attachment
# 
#   def uid_with_default_check
#     return nil if uid_without_default_check.nil?
#     if uid_without_default_check.match(/#{parent_model.class.to_s.downcase}_#{attribute_name}/)
#       nil
#     else
#       uid_without_default_check
#     end
#   end
#   alias_method_chain :uid, :default_check
# 
#   def previous_uid_with_default_check
#     return nil if previous_uid_without_default_check.nil?
#     if previous_uid_without_default_check.match(/#{parent_model.class.to_s.downcase}_#{attribute_name}/)
#       nil
#     else
#       previous_uid_without_default_check
#     end
#   end
#   alias_method_chain :previous_uid, :default_check
#   
# end
