class AddIndexesToWalls < ActiveRecord::Migration
  
  def self.up
    add_index :walls, :attachable_id
  end

  def self.down
    remove_index :walls, :attachable_id
  end
  
end
