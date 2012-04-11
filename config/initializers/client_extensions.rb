ActiveSupport::Dependencies.module_eval do
  
  def require_or_load_with_client_extensions(file_name, const_path = nil)
    match = file_name.match(/(#{RAILS_ROOT})(\/app\/.*\.rb)/)
    if match 
      client_file_name = "#{match[1]}/client#{match[2]}"
      if model_name = match[2].match(/\/app\/models\/(.+)\.rb/)
        # require any model concerns modules (e.g. SectionConcerns::Slugs)
        Dir["#{match[1]}/app/models/#{model_name}_concerns/*.rb"].each do |concern_file_name|
          require_or_load_without_client_extensions(concern_file_name, nil)
        end
      end
      require_or_load_without_client_extensions(client_file_name, const_path) if File.exists?(client_file_name)
    else
      client_match = file_name.match(/(#{RAILS_ROOT})\/client(\/app\/.*\.rb)/)
      if client_match
        plugin_file_name = Dir["#{client_match[1]}/vendor/plugins/**#{client_match[2]}"].first
        require_or_load_without_client_extensions(plugin_file_name, const_path) if plugin_file_name
      end
    end
    require_or_load_without_client_extensions(file_name, const_path)
  end
  alias_method_chain :require_or_load, :client_extensions
  
end

client_routes_file = "#{RAILS_ROOT}/client/config/routes.rb"
ActionController::Routing::Routes.add_configuration_file(client_routes_file) if File.exists?(client_routes_file)