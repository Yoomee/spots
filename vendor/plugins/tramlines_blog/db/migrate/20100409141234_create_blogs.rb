class CreateBlogs < ActiveRecord::Migration
  def self.up
    create_table :blogs do |t|
      t.string :name
      t.text :description
      t.integer :member_id
      t.string :image_uid
      t.timestamps
    end
  end
  
  def self.down
    drop_table :blogs
  end
end
