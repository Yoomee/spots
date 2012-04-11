class CreateBlogPosts < ActiveRecord::Migration
  def self.up
    create_table :blog_posts do |t|
      t.string :title
      t.text :text
      t.integer :member_id
      t.integer :blog_id
      t.string :image_uid
      t.timestamps
    end
  end
  
  def self.down
    drop_table :blog_posts
  end
end
