class AddConfirmedToTimeSlotBookings < ActiveRecord::Migration
  def self.up
    add_column :time_slot_bookings, :confirmed, :boolean, :default => false
  end

  def self.down
    remove_column :time_slot_bookings, :confirmed
  end
end
