require File.dirname(__FILE__) + '/../../../test/test_helper'
class TimeSlotQuestionTest < ActiveSupport::TestCase
  
  should have_db_column(:organisation_group_id).of_type(:integer)
  should have_db_column(:text).of_type(:string)
  should have_db_column(:field_type).of_type(:string).with_options(:default => "string")
  should have_db_column(:deleted_at).of_type(:datetime)
  should have_timestamps
  
  should belong_to(:organisation_group)
  should have_many(:time_slot_answers)
  
  should validate_presence_of(:organisation_group)
  should validate_presence_of(:text)
  should validate_presence_of(:field_type)
  
end