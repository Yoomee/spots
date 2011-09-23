class AddDeltasToSpotsModels < ActiveRecord::Migration
  
  def self.up
    add_column :activities, :delta, :boolean, :default => true
    add_column :organisations, :delta, :boolean, :default => true
  end

  def self.down
    remove_column :activities, :delta
    remove_column :organisations, :delta
  end
  
end
