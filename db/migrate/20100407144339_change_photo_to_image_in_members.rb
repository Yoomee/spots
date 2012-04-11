class ChangePhotoToImageInMembers < ActiveRecord::Migration
  
  def self.up
    rename_column :members, :photo_uid, :image_uid
  end

  def self.down
    rename_column :members, :image_uid, :photo_uid
  end
  
end
