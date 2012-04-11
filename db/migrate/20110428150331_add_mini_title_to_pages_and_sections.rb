class AddMiniTitleToPagesAndSections < ActiveRecord::Migration
  def self.up
    add_column :sections, :small_name, :string
    add_column :pages, :small_title, :string
  end

  def self.down
    remove_column :pages, :mini_title
    remove_column :sections, :mini_name
  end
end
