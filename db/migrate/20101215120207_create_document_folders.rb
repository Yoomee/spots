class CreateDocumentFolders < ActiveRecord::Migration
  def self.up
    create_table :document_folders do |t|
      t.string :name
      t.timestamps
    end
    add_column :documents, :folder_id, :integer
  end

  def self.down
    remove_column :documents, :folder_id
    drop_table :document_folders
  end
end
