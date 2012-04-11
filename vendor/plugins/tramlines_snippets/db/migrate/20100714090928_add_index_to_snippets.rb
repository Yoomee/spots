class AddIndexToSnippets < ActiveRecord::Migration
  
  def self.up
    add_index :snippets, [:item_id, :item_type]
  end

  def self.down
    remove_index :snippets, :column => [:item_id, :item_type]    
  end
  
end
