class CreatePhotoAlbums < ActiveRecord::Migration
  def self.up
    create_table :photo_albums do |t|
      t.string :name
      t.string :attachable_type
      t.integer :attachable_id
      t.boolean :system_album, :default => false
      t.timestamps
    end
  end
  
  def self.down
    drop_table :photo_albums
  end
end
