class AddWeightToActivities < ActiveRecord::Migration

  def self.up
    add_column :activities, :weight, :integer, :default => 0
  end

  def self.down
    remove_column :activities, :weight
  end
  
end
