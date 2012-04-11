class RemovingContentNamespace < ActiveRecord::Migration

  def self.up
    rename_table :content_pages, :pages
    rename_table :content_sections, :sections
  end

  def self.down
    rename_table :pages, :content_pages
    rename_table :sections, :content_sections
  end
  
end
