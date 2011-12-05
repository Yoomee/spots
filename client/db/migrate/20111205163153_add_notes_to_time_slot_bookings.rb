class AddNotesToTimeSlotBookings < ActiveRecord::Migration
  
  def self.up
    add_column :time_slot_bookings, :notes, :text
  end

  def self.down
    remove_column :time_slot_bookings, :notes
  end
  
end
