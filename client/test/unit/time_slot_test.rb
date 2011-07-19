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
  should have_many(:bookings)
  
  should validate_presence_of(:activity)
  should validate_presence_of(:organisation)
  should validate_presence_of(:starts_at)
  should validate_presence_of(:ends_at)
  
  context "a valid instance" do
    
    setup do
      @time_slot = Factory.build(:time_slot)
    end
    
    should "be valid" do
      @time_slot.valid?
    end
    
  end
  
  context "on call to possible_time_strings" do
    
    setup do
      @time_slot = Factory.build(:time_slot, :starts_at_string => "12:00", :ends_at_string => "16:00")
    end
    
    should "return correct array of time strings" do
      assert @time_slot.possible_time_strings, ["12:00", "13:00", "14:00", "15:00", "16:00"]
    end
    
  end
  
end