class AddPdfTextToDocuments < ActiveRecord::Migration
  def self.up
    add_column :documents, :pdf_text, :text, :limit => 65.kilobytes
  end

  def self.down
    remove_column :documents, :pdf_text
  end
end
