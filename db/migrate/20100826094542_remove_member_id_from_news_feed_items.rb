class RemoveMemberIdFromNewsFeedItems < ActiveRecord::Migration
  
  def self.up
    NewsFeedItem.all.each do |news_feed_item|
      news_feed_item.member_ids += [news_feed_item.member_id] unless news_feed_item.member_id.blank?
    end
    remove_column :news_feed_items, :member_id
  end

  def self.down
    add_column :news_feed_items, :member_id, :integer
  end
  
end
