Factory.class_eval do
  
  self.definition_file_paths += Dir["#{RAILS_ROOT}/vendor/plugins/**/test/"].map {|path| "#{path}/factories"}
  self.definition_file_paths << "#{RAILS_ROOT}/client/test/factories"

  class << self
    
    def redefine(name, options = {}, &block)
      self.factories.delete(name)
      define(name, options, &block)
    end
    
  end
  
end