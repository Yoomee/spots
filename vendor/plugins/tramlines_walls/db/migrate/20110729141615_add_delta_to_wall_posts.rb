class AddDeltaToWallPosts < ActiveRecord::Migration
  def self.up
    add_column :wall_posts, :delta, :boolean, :default => true
  end

  def self.down
    remove_column :wall_posts, :delta
  end
end
