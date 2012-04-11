# Include hook code here
%w(controllers helpers models views).each {|path| ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'app', path) }

class ActiveRecord::Base
  
  class << self
    
    def has_permalink(options = {})
      include HasPermalink      
      self.auto_update_permalink = Module::value_to_boolean(options[:auto_update])
    end

  end
  
end

ActionController::Routing::RouteSet::NamedRouteCollection.class_eval do

  private
  def define_named_route_methods_with_permalinks(name, route)
    define_named_route_methods_without_permalinks(name, route)
    # TODO - beware of custom REST actions
    if model_name = model_name(name.to_s)
      named_helper_module_eval("

        def #{url_helper_name(name, 'path')}_with_permalinks(*args)
          args = args.flatten
          get_#{name}_permalink_path(*args) || #{url_helper_name(name, 'path')}_without_permalinks(*args)
        end
        alias_method_chain :#{url_helper_name(name, 'path')}, :permalinks

        def get_#{name}_permalink_path(*args)          
          return nil unless args && args.first
          model_instance = get_#{name}_model_instance(args.first)
          return nil unless permalink_path = model_instance.try(:permalink_path)
          args_arg = args.first.is_a?(Hash) ? args.first : args.second
          if args_arg
            args_hash = args_arg.dup
            args_hash.delete(:id)
            params = ActionController::Routing::Route.new.build_query_string(args_hash)
          else
            params = ''
          end
          permalink_path + params
        end

        def get_#{name}_model_instance(obj)
          case obj
            when #{model_name}
              obj
            when Hash
              begin
                #{model_name}.find(obj[:id])
              rescue ActiveRecord::RecordNotFound
                nil
              end
            else
              begin
                #{model_name}.find(obj)
              rescue ActiveRecord::RecordNotFound
                nil
              end
          end
        end

      ", __FILE__, __LINE__)
    end
  end
  alias_method_chain :define_named_route_methods, :permalinks

  def model_name(name)
    begin
      model_name = name.camelcase.constantize
      if !(name =~ /^(new|edit)_/) && name.singularize == name && model_name.included_modules.include?(HasPermalink)
        model_name
      else
        nil
      end
    rescue NameError
      # ie. name is not a model
      nil
    rescue ActiveRecord::StatementInvalid
      # Presumably, the table doesn't exist (ie. you might be trying to run the necessary migrations)
      nil
    end
  end
    
  
end

config.middleware.insert_before ActionController::Failsafe, PermalinksHandler unless RAILS_ENV == 'cucumber'
