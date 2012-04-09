class TimeSlotAnswer < ActiveRecord::Base
  
  belongs_to :time_slot_question
  belongs_to :time_slot_booking
  
  validates_presence_of :time_slot_question
  
  def question_field_type
    field_type = time_slot_question.try(:field_type)
    field_type.in?(%{string text}) ? field_type : "string"
  end
  
  def question_text
    time_slot_question.try(:text)
  end
  
  def question_text_with_colon
    return question_text if question_text.blank?
    question_text.strip.ends_with?('?') ? question_text.strip : "#{question_text.strip}:"
  end
  
end