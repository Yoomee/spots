class CreateBlogCategories < ActiveRecord::Migration
  def self.up
    create_table :blog_post_categories do |t|
      t.string :name
      t.integer :member_id
      t.timestamps
    end
    
    create_table :blog_post_categories_blog_posts, :id => false do |t|
      t.integer :blog_post_id
      t.integer :blog_post_category_id
    end
    
  end
  
  def self.down
    drop_table :blog_post_categories
    drop_table :blog_post_categories_blog_posts
  end
end
