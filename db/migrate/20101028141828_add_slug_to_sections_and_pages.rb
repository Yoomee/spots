class AddSlugToSectionsAndPages < ActiveRecord::Migration
  
  def self.up
    add_column :sections, :slug, :string
    add_column :pages, :slug, :string
  end

  def self.down
    remove_column :sections, :slug
    remove_column :pages, :slug
  end
  
end
