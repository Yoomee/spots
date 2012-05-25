class AddOrganisationDescriptionToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :organisation_description, :text
  end

  def self.down
    remove_column :activities, :organisation_description
  end
end
