class CreateTimeSlots < ActiveRecord::Migration
  def self.up
    create_table :time_slots do |t|
      t.integer :activity_id
      t.integer :organisation_id
      t.text :note
      t.datetime :starts_at
      t.datetime :ends_at
      %w{mon tue wed thu fri sat sun}.each do |day|
        t.boolean day.to_sym
      end
    end
  end

  def self.down
    drop_table :time_slots    
  end
end
