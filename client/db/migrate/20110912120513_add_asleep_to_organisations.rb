class AddAsleepToOrganisations < ActiveRecord::Migration
  
  def self.up
    change_table :organisations do |t|
      t.boolean :awake, :null => false, :default => true
      t.remove :active
    end
  end

  def self.down
    change_table :organisations do |t|
      t.boolean :active, :default => false
      t.remove :awake
    end
  end

end
