class AddIndexToLocations < ActiveRecord::Migration
  def self.up
    add_index :locations, [:attachable_id, :attachable_type]
  end

  def self.down
    remove_index :locations, :column => [:attachable_id, :attachable_type]
  end
end
