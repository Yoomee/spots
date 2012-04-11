class AddDeltaToMedia < ActiveRecord::Migration
  def self.up
    add_column :links, :delta, :boolean, :default => true, :null => true
    add_column :photos, :delta, :boolean, :default => true, :null => true
    add_column :videos, :delta, :boolean, :default => true, :null => true        
  end

  def self.down
    remove_column :links, :delta
    remove_column :photos, :delta
    remove_column :videos, :delta    
  end
end
