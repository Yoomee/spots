class CreateLinks < ActiveRecord::Migration
  
  def self.up
    create_table :links do |t|
      t.string :name
      t.text :description
      t.string :url
      t.string :image_uid
      t.integer :member_id
      t.integer :attachable_id
      t.string :attachable_type
      t.timestamps
    end
    add_index :links, :member_id
    add_index :links, :attachable_id
  end
  
  def self.down
    drop_table :links
  end
end
