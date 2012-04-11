class AddPhotoIdToSections < ActiveRecord::Migration
  def self.up
    remove_column :sections, :image_uid
    add_column :sections, :photo_id, :integer, :null => true, :default => nil
  end

  def self.down
    remove_column :sections, :photo_id
    add_column :sections, :image_uid, :string
  end
end
