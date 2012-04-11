class CreateOldPermalinks < ActiveRecord::Migration
  
  def self.up
    create_table :old_permalinks do |t|
      t.string :name
      t.belongs_to :model, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :old_permalinks
  end
  
end
