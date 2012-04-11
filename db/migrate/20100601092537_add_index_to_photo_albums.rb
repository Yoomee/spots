class AddIndexToPhotoAlbums < ActiveRecord::Migration
  def self.up
    add_index :photo_albums, :attachable_id
  end
  
  def self.down
    remove_index :photo_albums, :attachable_id
  end
end
