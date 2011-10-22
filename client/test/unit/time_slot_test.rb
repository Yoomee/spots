# Copyright 2011 Yoomee Digital Ltd.
# 
# This software and associated documentation files (the
# "Software") was created by Yoomee Digital Ltd. or its agents
# and remains the copyright of Yoomee Digital Ltd or its agents
# respectively and may not be commercially reproduced or resold
# unless by prior agreement with Yoomee Digital Ltd.
# 
# Yoomee Digital Ltd grants Spots of Time (the "Client") 
# the right to use this Software subject to the
# terms or limitations for its use as set out in any proposal
# quotation relating to the Work and agreed by the Client.
# 
# Yoomee Digital Ltd is not responsible for any copyright
# infringements caused by or relating to materials provided by
# the Client or its agents. Yoomee Digital Ltd reserves the
# right to refuse acceptance of any material over which
# copyright may apply unless adequate proof is provided to us of
# the right to use such material.
# 
# The Client shall not be permitted to sub-license or rent or
# loan or create derivative works based on the whole or any part
# of the Works supplied by us under this agreement without prior
# written agreement with Yoomee Digital Ltd.
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