class AddingWalls < ActiveRecord::Migration
  
  def self.up
    create_table :walls do |t|
      t.integer :attachable_id
      t.string :attachable_type
      t.string :name
      t.timestamps
    end
    
  end

  def self.down
    drop_table :walls
  end

end
