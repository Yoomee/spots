class AddPhotoToMembers < ActiveRecord::Migration
  
  def self.up
    add_column :members, :photo_uid, :string
  end

  def self.down
    remove_column :members, :photo_uid
  end
  
end
