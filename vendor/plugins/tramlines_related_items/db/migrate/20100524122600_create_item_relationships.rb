class CreateItemRelationships < ActiveRecord::Migration
  def self.up
    create_table :item_relationships do |t|
      t.integer :item_id
      t.string :item_type
      t.integer :related_item_id
      t.string :related_item_type
      t.timestamps
    end
  end

  def self.down
    drop_table :item_relationships
  end
end
