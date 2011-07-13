require File.dirname(__FILE__) + '/../../../test/test_helper'
class TimeSlotTest < ActiveSupport::TestCase
  
  should have_db_column(:activity_id).of_type(:integer)
  should have_db_column(:organisation_id).of_type(:integer)
  should have_db_column(:note).of_type(:text)
  should have_db_column(:starts_at).of_type(:datetime)
  should have_db_column(:ends_at).of_type(:datetime)
  should have_db_column(:mon).of_type(:boolean)
  should have_db_column(:tue).of_type(:boolean)
  should have_db_column(:wed).of_type(:boolean)
  should have_db_column(:thu).of_type(:boolean)
  should have_db_column(:fri).of_type(:boolean)  
  should have_db_column(:sat).of_type(:boolean)  
  should have_db_column(:sun).of_type(:boolean)
  
  
  should belong_to(:activity)
  should belong_to(:organisation)
  
  should validate_presence_of(:activity)
  should validate_presence_of(:organisation)
  should validate_presence_of(:starts_at)
  should validate_presence_of(:ends_at)
  
end