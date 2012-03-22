class CreateTimeSlotAnswers < ActiveRecord::Migration
  
  def self.up
    create_table :time_slot_answers do |t|
      t.belongs_to :time_slot_question
      t.belongs_to :time_slot_booking
      t.text :text
      t.timestamps
    end
  end

  def self.down
    drop_table :time_slot_answers
  end
  
end
