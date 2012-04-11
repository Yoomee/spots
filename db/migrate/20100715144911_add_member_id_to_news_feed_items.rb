class AddMemberIdToNewsFeedItems < ActiveRecord::Migration
  
  def self.up
    add_column :news_feed_items, :member_id, :integer
    add_index :news_feed_items, :member_id
  end

  def self.down
    remove_column :news_feed_items, :member_id
  end
  
end
