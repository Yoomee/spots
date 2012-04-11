class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :name
      t.string :file_uid
      t.string :file_name
      t.string :file_ext
      t.integer :member_id
      t.boolean :delta, :default => true, :null => true
      t.timestamps
    end
    add_index :documents, :member_id
  end
  
  def self.down
    drop_table :documents
  end
end
