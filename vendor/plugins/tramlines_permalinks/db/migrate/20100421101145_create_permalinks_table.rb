class CreatePermalinksTable < ActiveRecord::Migration

  def self.up
    create_table :permalinks do |t|
      t.string :name
      t.string :model_type
      t.integer :model_id
    end
  end

  def self.down
    drop_table :permalinks
  end
end
