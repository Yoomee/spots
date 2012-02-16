class AddOrganisationGroupIdToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :organisation_group_id, :integer
  end

  def self.down
    remove_column :activities, :organisation_group_id, :integer
  end
end
