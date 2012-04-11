class CreatePullQuotes < ActiveRecord::Migration

  def self.up
    create_table :pull_quotes do |t|
      t.string :item_type
      t.integer :item_id
      t.string :name
      t.text :text
    end
  end

  def self.down
    drop_table :pull_quotes
  end
  
end
