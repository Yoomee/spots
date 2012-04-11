%w(controllers helpers models views).each do |path|
  ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'app', path)
end
ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'lib')

ActiveRecord::Base.class_eval do
   
  class << self

    DEFAULT_RELATED_MODELS = [:pages, :sections, :documents, :members, :photos, :links, :videos]

    def has_related_items(*related_models)
      related_models = related_models.flatten.empty? ? DEFAULT_RELATED_MODELS : related_models.flatten
      self.send(:class_variable_set, :@@related_models, related_models)
      send(:include, HasRelatedItems)
    end

  end
  
end