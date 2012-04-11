class AddFieldsToLinks < ActiveRecord::Migration
  
  def self.up
    add_column :links, :title, :string    
    add_column :links, :url_error, :boolean, :default => false
  end

  def self.down
    remove_column :links, :title
    remove_column :links, :url_error
  end
  
end
