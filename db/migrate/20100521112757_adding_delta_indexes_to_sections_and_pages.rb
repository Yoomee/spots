class AddingDeltaIndexesToSectionsAndPages < ActiveRecord::Migration

  def self.up
    add_column :sections, :delta, :boolean, :default => true, :null => false
    add_column :pages, :delta, :boolean, :default => true, :null => true
  end

  def self.down
    remove_column :sections, :delta
    remove_column :pages, :delta
  end
  
end
