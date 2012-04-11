class AddPhotoIdToBlogPosts < ActiveRecord::Migration
  
  def self.up
    remove_column :blog_posts, :image_uid
    add_column :blog_posts, :photo_id, :integer
  end

  def self.down
    remove_column :blog_posts, :photo_id
    add_column :blog_posts, :image_uid, :integer
  end
  
end
