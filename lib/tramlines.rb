class Tramlines
  
  #unloadable
  
  @@plugins = Set.new
  
  class << self
    
    def add_plugin(plugin)
      @@plugins << plugin.to_s
      self.send(:include, "Tramlines#{plugin.to_s.camelcase}".constantize)
    end
    
    def load_plugins
      require_dependency "#{RAILS_ROOT}/config/plugins.rb"
      plugins_file = "#{RAILS_ROOT}/client/config/plugins.rb"
      require_dependency plugins_file if File.exists?(plugins_file)
    end
    
    def uses_plugin?(plugin)
      load_plugins
      @@plugins.include?(plugin.to_s)
    end
    
  end
  
end