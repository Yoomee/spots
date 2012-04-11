class AddImageCentreToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :image_centre, :string
  end

  def self.down
    remove_column :photos, :image_centre
  end
end
