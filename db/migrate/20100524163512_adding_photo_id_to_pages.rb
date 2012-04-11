class AddingPhotoIdToPages < ActiveRecord::Migration

  def self.up
    add_column :pages, :photo_id, :integer, :null => true, :default => nil
  end

  def self.down
    remove_column :pages, :photo_id
  end
  
end
