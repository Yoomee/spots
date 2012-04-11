class RenamingPullQuotesToSnippets < ActiveRecord::Migration

  def self.up
    rename_table :pull_quotes, :snippets
  end

  def self.down
    rename_table :snippets, :pull_quotes
  end
  
end
