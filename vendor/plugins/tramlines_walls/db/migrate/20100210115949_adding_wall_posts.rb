class AddingWallPosts < ActiveRecord::Migration

  def self.up
    create_table :wall_posts do |t|
      t.integer :member_id
      t.integer :wall_id
      t.string :text
      t.timestamps
    end    
  end

  def self.down
    drop_table :wall_posts
  end
  
end
