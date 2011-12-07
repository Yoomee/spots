class AddOrganisationIdToDocuments < ActiveRecord::Migration
  
  def self.up
    add_column :documents, :organisation_id, :integer
  end

  def self.down
    remove_column :documents, :organisation_id
  end
  
end
