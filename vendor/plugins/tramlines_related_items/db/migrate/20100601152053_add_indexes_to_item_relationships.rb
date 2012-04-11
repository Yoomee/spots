class AddIndexesToItemRelationships < ActiveRecord::Migration
  def self.up
    add_index :item_relationships, [:item_id, :item_type], :name => "item_relationship_item"
    add_index :item_relationships, [:item_id, :item_type, :related_item_id, :related_item_type], 
                  :unique => true, 
                  :name => 'item_relationship_unique_index'
  end

  def self.down
    remove_index :item_relationships, :name => "item_relationship_item"
    remove_index :item_relationships, :name => "item_relationship_unique_index"    
  end
end
