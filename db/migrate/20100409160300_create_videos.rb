class CreateVideos < ActiveRecord::Migration
  
  def self.up
    create_table :videos do |t|
      t.string :name
      t.text :description
      t.string :url
      t.text :html
      t.string :image_uid
      t.integer :member_id
      t.integer :attachable_id
      t.string :attachable_type
      t.timestamps
    end
    add_index :videos, :member_id
    add_index :videos, :attachable_id
  end
  
  def self.down
    drop_table :videos
  end
end
