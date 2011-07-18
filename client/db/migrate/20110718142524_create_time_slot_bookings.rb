class CreateTimeSlotBookings < ActiveRecord::Migration
  def self.up
    create_table :time_slot_bookings do |t|
      t.belongs_to :member
      t.belongs_to :time_slot
      t.datetime :starts_at
      t.timestamps
    end
  end

  def self.down
    drop_table :time_slot_bookings
  end
end
