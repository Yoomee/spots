class AddConfirmedToOrganisations < ActiveRecord::Migration
  
  def self.up
    add_column :organisations, :confirmed, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :organisations, :confirmed
  end
  
end
