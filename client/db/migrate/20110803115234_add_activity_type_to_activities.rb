class AddActivityTypeToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :activity_type, :string, :default => "volunteering"
  end

  def self.down
    remove_column :activities, :activity_type
  end
end
