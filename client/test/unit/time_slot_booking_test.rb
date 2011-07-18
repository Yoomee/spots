require File.dirname(__FILE__) + '/../../../test/test_helper'
class TimeSlotBookingTest < ActiveSupport::TestCase
  
  should have_db_column(:member_id)
  should have_db_column(:time_slot_id)
  should have_db_column(:starts_at)
  should have_timestamps
  
  should belong_to(:member)
  should belong_to(:time_slot)
  
  should validate_presence_of(:member)
  should validate_presence_of(:time_slot)
  should validate_presence_of(:starts_at)  
  
  context "a valid instance" do
    
    setup do
      @time_slot_booking = Factory.build(:time_slot_booking)
    end
    
    should "be valid" do
      @time_slot_booking.valid?
    end
    
  end
  
  context "an instance" do
    
    setup do
      @time_slot = Factory.build(:time_slot)
      @time_slot_booking = Factory.build(:time_slot_booking, :time_slot => @time_slot)
    end
    
    should "be invalid if new_record and starts_at is in the past" do
      @time_slot_booking.starts_at = 1.day.ago
      assert !@time_slot_booking.valid?
    end
    
    should "be invalid if starts_at is before time_slot's starts_at" do
      @time_slot.starts_at_string = "12:00"
      @time_slot_booking.starts_at = Time.parse("10:00", 1.day.from_now)
      assert !@time_slot_booking.valid?
    end
    
    should "be invalid if starts_at is after time_slot's ends_at" do
      @time_slot.ends_at_string = "12:00"
      @time_slot_booking.starts_at = Time.parse("13:00", 1.day.from_now)
      assert !@time_slot_booking.valid?
    end
    
    should "be invalid if starts_at is not on any of time_slot's allowed days" do
      @time_slot.mon = false
      date = Time.parse("12:00", 1.day.from_now)
      until date.wday == 1
        date = date + 1.day
      end
      @time_slot_booking.starts_at = date
      assert !@time_slot_booking.valid?
    end
    
    should "be invalid if booking already exists for the time_slot on the same day" do
      @time_slot = Factory.create(:time_slot, :id => 1)
      Factory.create(:time_slot_booking, :time_slot => @time_slot, :starts_at => Time.parse("09:00", 1.day.from_now))
      @time_slot_booking.attributes = {:time_slot => @time_slot, :starts_at => Time.parse("10:00", 1.day.from_now)}
      assert !@time_slot_booking.valid?
    end
    
    should "be invalid if starts_at is earlier than the notice period" do
      @time_slot.expects(:num_weeks_notice).at_least_once.returns 2
      @time_slot_booking.starts_at = Time.parse("12:00", 3.weeks.ago)
      assert !@time_slot_booking.valid?
    end
    
    should "be invalid if starts_at is later than the notice period" do
      @time_slot.expects(:num_weeks_notice).at_least_once.returns 2
      @time_slot_booking.starts_at = Time.parse("12:00", 3.weeks.from_now)
      assert !@time_slot_booking.valid?
    end
    
  end
  
end