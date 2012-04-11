class AddTimestampsToSnippets < ActiveRecord::Migration
  
  def self.up
    add_timestamps(:snippets)
  end

  def self.down
    remove_timestamps(:snippets)
  end
end
