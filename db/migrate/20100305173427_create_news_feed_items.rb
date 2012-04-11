class CreateNewsFeedItems < ActiveRecord::Migration
  
  def self.up
    create_table :news_feed_items do |t|
      t.integer :attachable_id
      t.string :attachable_type
      t.string :attribute_changes
      t.boolean :updated, :default => false
      t.integer :weighting
      t.timestamps
    end
    add_index :news_feed_items, :attachable_id
  end

  def self.down
    drop_table :news_feed_items
  end
  
end
