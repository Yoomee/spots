require File.dirname(__FILE__) + '/../../../test/test_helper'
class TimeSlotAnswerTest < ActiveSupport::TestCase
  
  should have_db_column(:time_slot_question_id).of_type(:integer)
  should have_db_column(:time_slot_booking_id).of_type(:integer)
  should have_db_column(:text).of_type(:text)
  should have_timestamps
  
  should belong_to(:time_slot_question)
  should belong_to(:time_slot_booking)
  
  should validate_presence_of(:time_slot_question)
  
end