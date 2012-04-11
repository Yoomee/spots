class AddIndexesToWallPosts < ActiveRecord::Migration
  
  def self.up
    add_index :wall_posts, :wall_id
  end

  def self.down
    remove_index :wall_posts, :wall_id
  end
  
end
