class AddAttendedToTimeSlotBookings < ActiveRecord::Migration
  
  def self.up
    add_column :time_slot_bookings, :attended, :boolean, :default => false
  end

  def self.down
    remove_column :time_slot_bookings, :attended
  end
  
end
