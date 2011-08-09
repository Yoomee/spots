class AddGroupTypeAndSizeOfOrganisationToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :group_type, :string
    add_column :organisations, :size_of_organisation, :string
  end

  def self.down
    remove_column :organisations, :size_of_organisation
    remove_column :organisations, :group_type
  end
end
