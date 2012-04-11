class CreateMembersNewsFeedItems < ActiveRecord::Migration
  
  def self.up
    create_table :members_news_feed_items, :id => false do |t|
      t.integer :member_id      
      t.integer :news_feed_item_id      
    end
  end

  def self.down
    drop_table :members_news_feed_items
  end
  
end
