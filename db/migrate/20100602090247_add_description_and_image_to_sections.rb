class AddDescriptionAndImageToSections < ActiveRecord::Migration

  def self.up
    add_column :sections, :description, :text
    add_column :sections, :image_uid, :string
  end

  def self.down
    remove_column :sections, :description
    remove_column :sections, :image_uid
  end

end
