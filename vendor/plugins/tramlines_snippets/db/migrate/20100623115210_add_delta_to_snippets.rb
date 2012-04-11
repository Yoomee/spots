class AddDeltaToSnippets < ActiveRecord::Migration
  
  def self.up
    add_column :snippets, :delta, :boolean, :default => true, :null => true
  end

  def self.down
    remove_column :snippets, :delta
  end
  
end

