class AddingImageUidToContentPages < ActiveRecord::Migration
  
  def self.up
    add_column :content_pages, :image_uid, :string
  end

  def self.down
    remove_column :content_pages, :image_uid
  end
  
end
