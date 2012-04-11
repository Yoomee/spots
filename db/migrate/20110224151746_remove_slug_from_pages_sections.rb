class RemoveSlugFromPagesSections < ActiveRecord::Migration
  def self.up
    remove_column(:pages, :slug) if Page.column_names.include?("slug")
    remove_column(:sections, :slug) if Section.column_names.include?("slug")
  end

  def self.down
  end
end
