ActsAsTaggableOn::Tag.class_eval do
  
  def to_tag
    Tag.find(id)
  end
  
  def <=>(tag)
    name <=> tag.name
  end
  
end

ActsAsTaggableOn::Tagging.class_eval do
  
  after_destroy :delete_tag
  
  private
  def delete_tag
    tag.destroy unless !tag.taggings.empty?
  end
  
end

ActsAsTaggableOn::Taggable::Core::ClassMethods.module_eval do
  
  def tagged_with_with_hash_conversion(tags, options = {})
    result = tagged_with_without_hash_conversion(tags, options)
    result == {} ? scoped(:conditions => 'FALSE') : result
  end
  alias_method_chain :tagged_with, :hash_conversion
  
end