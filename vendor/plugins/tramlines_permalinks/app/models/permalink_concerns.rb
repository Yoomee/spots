module PermalinkConcerns
  
  def self.included(klass)
    klass.belongs_to(:model, :polymorphic => true)
    klass.validates_presence_of(:name)
  end
  
  def name=(value)
    value = value.urlify unless value.nil?
    write_attribute(:name, value)
  end

  def model_path(method = 'get', env_options = {})
    method = method.to_s.downcase
    if model_type == 'Section' && method == 'get'
      "/#{model.destination_type.tableize}/#{model.destination_id}"
    else
      "/#{model_type.tableize}/#{model_id}"
    end
  end

end