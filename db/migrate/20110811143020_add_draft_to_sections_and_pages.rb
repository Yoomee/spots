class AddDraftToSectionsAndPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :draft, :boolean, :default => false
    add_column :sections, :draft, :boolean, :default => false
  end

  def self.down
    remove_column :pages, :draft
    remove_column :sections, :draft
  end
end
