module HasRelatedItems
  
  def self.included(klass)
    klass.has_many :real_item_relationships, :as => :item, :class_name => "ItemRelationship", :dependent => :destroy, :autosave => true                                                  
    klass.accepts_nested_attributes_for :real_item_relationships, :allow_destroy => true 
    klass.has_many :item_relationships, :as => :item, :dependent => :destroy, :autosave => true
    begin
      klass.has_many_polymorphs :related_items, :from             => klass.send(:class_variable_get, '@@related_models'),
                                                :through          => :item_relationships,
                                                :as               => :item,
                                                :foreign_key      => :item_id,
                                                :foreign_type_key => :item_type,
                                                :rename_individual_collections => true
    rescue ActiveRecord::Associations::PolymorphicError
      # not all related items models are setup yet - perhaps in a migration?
    end
    klass.send(:alias_method_chain, :method_missing, :related_items)
    # The Rails built-in way isn't working, so:
    klass.after_save :destroy_marked_item_relationships
  end
  
  def has_related_items?(options = {})
    if options[:excluded_types]
      !related_items.excluding_related_types(options[:excluded_types]).count.zero?
    elsif options[:included_types]
      !related_items.including_related_types(options[:included_types]).count.zero?
    else
      !related_items.count.zero?
    end
  end
  
  def method_missing_with_related_items(method_id, *args)
    method_name = method_id.to_s
    if match = method_name.match(/^related_(\w+)/)
      unless match[1].match(/^item/)
        return related_items.including_related_types([match[1].classify])
      end
    elsif match = method_name.match(/^has_related_(\w+)\?$/)
      return has_related_items?(:included_types => [match[1].classify])
    end
    method_missing_without_related_items(method_id, *args)
  end
  
  def destroy_marked_item_relationships
    real_item_relationships.select(&:marked_for_destruction?).each &:destroy
  end
  
end