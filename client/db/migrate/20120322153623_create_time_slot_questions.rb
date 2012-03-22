class CreateTimeSlotQuestions < ActiveRecord::Migration
  
  def self.up
    create_table :time_slot_questions do |t|
      t.belongs_to :organisation_group
      t.string :text
      t.string :field_type, :default => "string"
      t.datetime :deleted_at
      t.timestamps
    end
  end

  def self.down
    drop_table :time_slot_questions
  end
end
