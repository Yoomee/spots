class ItemRelationship < ActiveRecord::Base
  
  belongs_to :item, :polymorphic => true
  belongs_to :related_item, :polymorphic => true
  
  named_scope :excluding_related_types, lambda{|types| {:conditions => ["related_item_type NOT IN (?)", types]}}  
  named_scope :including_related_types, lambda{|types| {:conditions => ["related_item_type IN (?)", types]}}  
end