ActionController::Base.class_eval do
  
  class << self
    
    def arrange_view_paths
      prepend_view_path("#{RAILS_ROOT}/client/app/views")
      view_paths.delete("#{RAILS_ROOT}/app/views")
      append_view_path("#{RAILS_ROOT}/app/views")
    end
    
    def process_with_tramlines_plugins(*args)
      Tramlines::load_plugins
      process_without_tramlines_plugins(*args)
    end
    alias_method_chain :process, :tramlines_plugins

  end
  
end

ActionController::Filters::ClassMethods.class_eval do
  
  def append_before_filter_with_subclassing(*filters, &block)
    append_before_filter_without_subclassing(*filters, &block)
    subclasses.each do |subclass_name|
      subclass_name.constantize.append_before_filter_without_subclassing(*filters, &block)
    end
  end
  alias_method_chain :append_before_filter, :subclassing
  alias_method :before_filter, :append_before_filter
  
end

ActionController::Helpers::ClassMethods.module_eval do  
  
  def all_application_helpers_with_client_and_engines
     all_application_helpers_without_client_and_engines + client_helpers + engines_helpers
  end
  alias_method_chain :all_application_helpers, :client_and_engines

  def client_helpers
    client_helpers_dir_regexp = /#{RAILS_ROOT}\/client\/app\/helpers\/(.+)_helper.rb$/
    client_helpers_dir_glob = "#{RAILS_ROOT}/client/app/helpers"
    Dir["#{client_helpers_dir_glob}/**/*_helper.rb"].map {|file| file.sub(client_helpers_dir_regexp, '\1')}
  end

  def engines_helpers
    engines_helpers_dir_regexp = /#{RAILS_ROOT}\/vendor\/plugins\/.+\/app\/helpers\/(.+)_helper.rb$/
    engines_helpers_dir_glob = "#{RAILS_ROOT}/vendor/plugins/**/app/helpers"
    Dir["#{engines_helpers_dir_glob}/**/*_helper.rb"].map {|file| file.sub(engines_helpers_dir_regexp, '\1')}
  end

end

ActionController::Routing::RouteSet::NamedRouteCollection.class_eval do
    
  private
  def define_named_route_methods_with_proc_generation(name, route)
    define_named_route_methods_without_proc_generation(name, route)
    proc_name = url_helper_name(name, 'proc')
    # path_name = url_helper_name(name, 'path')
    # url_name = url_helper_name(name, 'url')
    named_helper_module_eval("
    
      def #{proc_name}(*args)
        if args.empty?
          args = nil
          hash_args = nil
        else
          if args.first.is_a?(Hash)
            hash_args = args.dup.delete_at(0)
          else
            hash_args = {:id => args.dup.delete_at(0)}
          end
        end
        Proc.new{|kind|
          case kind.to_sym
            when :path
              args.nil? ? #{url_helper_name(name, 'path')} : #{url_helper_name(name, 'path')}(*args)
            when :url
              args.nil? ? #{url_helper_name(name, 'url')} : #{url_helper_name(name, 'url')}(*args)
            when :path_hash
              if hash_args
                #{hash_access_name(name, 'path')}(hash_args)
              else
                #{hash_access_name(name, 'path')}
              end
            when :url_hash
              if hash_args
                #{hash_access_name(name, 'url')}(hash_args)
              else
                #{hash_access_name(name, 'url')}
              end
          end
        }
      end
      
    ", __FILE__, __LINE__)
    helpers << proc_name
  end
  alias_method_chain :define_named_route_methods, :proc_generation
  
end
