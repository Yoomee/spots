class AddOrganisationGroupIdToOrganisations < ActiveRecord::Migration
  def self.up
    add_column :organisations, :organisation_group_id, :integer
    add_index :organisations, :organisation_group_id
  end

  def self.down
    remove_column :organisations, :organisation_group_id
  end
end
