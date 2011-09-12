class AddActivityIdToDocuments < ActiveRecord::Migration
  
  def self.up
    add_column :documents, :activity_id, :integer
    add_index :documents, :activity_id
  end

  def self.down
    remove_column :documents, :activity_id
  end
  
end
