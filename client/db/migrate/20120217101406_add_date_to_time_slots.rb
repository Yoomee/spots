class AddDateToTimeSlots < ActiveRecord::Migration
  def self.up
    add_column :time_slots, :date, :date
  end

  def self.down
    remove_column :time_slots, :date
  end
end
