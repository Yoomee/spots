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
class OrganisationTest < ActiveSupport::TestCase
  
  should have_db_column(:awake).of_type(:boolean).with_options(:default => true)
  should have_db_column(:confirmed).of_type(:boolean).with_options(:default => false)
  should have_db_column(:description).of_type(:text)  
  should have_db_column(:email_each_day).of_type(:boolean).with_options(:default => false)
  should have_db_column(:email_each_week).of_type(:boolean).with_options(:default => false)
  should have_db_column(:image_uid).of_type(:string)
  should have_db_column(:member_id).of_type(:integer)
  should have_db_column(:name).of_type(:string)
  should have_db_column(:organisation_group_id).of_type(:integer)
  should have_db_column(:num_weeks_notice).of_type(:integer)
  should have_db_column(:phone).of_type(:string)
  should have_db_column(:require_crb).of_type(:boolean)
  should have_db_column(:terms).of_type(:text)
  should have_db_column(:volunteers_insured).of_type(:boolean)
  should have_timestamps
  
  should belong_to(:member)
  should belong_to(:organisation_group)
  should have_many(:time_slots)
  should have_many(:documents)
  
  should validate_presence_of(:member)
  should validate_presence_of(:name)
  should validate_presence_of(:phone)
  
  context "on call to next_available_date_for_activity" do
    
    setup do
      @organisation = Factory.create(:organisation, :num_weeks_notice => 2)
      @activity = Factory.create(:activity)
      @time_slot = Factory.build(:time_slot, :activity => @activity, :organisation => @organisation, :mon => false, :tue => false, :wed => false, :thu => false, :fri => false, :sat => false, :sun => false)
    end
    
    context "if today is a Wed 01/02/2012" do
      
      setup do
        Timecop.freeze(Date.new(2012, 2, 1))
      end
      
      teardown do
        Timecop.return
      end
      
      should "return Monday 20/02/2012 if time_slots contain a mon but no other days" do
        @time_slot.update_attributes(:mon => true)
        assert_equal "2012-02-20", @organisation.next_available_date_for_activity(@activity).strftime("%Y-%m-%d")
      end
      
      should "return Friday 17/02/2012 if time_slots contain a fri, sat and sun but no other days" do
        @time_slot.update_attributes(:fri => true, :sat => true, :sun => true)
        assert_equal "2012-02-17", @organisation.next_available_date_for_activity(@activity).strftime("%Y-%m-%d")        
      end
      
      should "return a Wednesday 15/02/2012 if time_slots contain all days" do
        @time_slot.update_attributes(:mon => true, :tue => true, :wed => true, :thu => true, :fri => true, :sat => true, :sun => true)
        assert_equal "2012-02-15", @organisation.next_available_date_for_activity(@activity).strftime("%Y-%m-%d")
      end
      
      should "return Tuesday 21/02/2012 if time_slots contain a mon and tues but the mon is booked" do
        @time_slot.update_attributes(:mon => true, :tue => true)
        Factory.create(:time_slot_booking, :time_slot => @time_slot, :starts_at => Time.parse(@time_slot.possible_time_strings.first, Date.new(2012,2,20)))
        assert_equal "2012-02-21", @organisation.next_available_date_for_activity(@activity).strftime("%Y-%m-%d")
      end
      
    end
    
  end
  
end
