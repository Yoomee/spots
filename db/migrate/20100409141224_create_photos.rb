class CreatePhotos < ActiveRecord::Migration
  
  def self.up
    create_table :photos do |t|
      t.string :name
      t.text :description
      t.string :image_uid
      t.integer :member_id
      t.integer :attachable_id
      t.string :attachable_type
      t.timestamps
    end
    add_index :photos, :member_id
    add_index :photos, :attachable_id
  end
  
  def self.down
    drop_table :photos
  end
end
