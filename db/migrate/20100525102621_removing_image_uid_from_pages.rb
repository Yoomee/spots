class RemovingImageUidFromPages < ActiveRecord::Migration

  def self.up
    remove_column :pages, :image_uid
  end

  def self.down
    add_column :pages, :image_uid, :string
  end
  
end
