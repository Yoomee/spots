require File.dirname(__FILE__) + '/../../../test/test_helper'
class OrganisationTest < ActiveSupport::TestCase
  
  should have_db_column(:awake).of_type(:boolean).with_options(:default => true)
  should have_db_column(:confirmed).of_type(:boolean).with_options(:default => false)
  should have_db_column(:description).of_type(:text)  
  should have_db_column(:image_uid).of_type(:string)
  should have_db_column(:member_id).of_type(:integer)
  should have_db_column(:name).of_type(:string)
  should have_db_column(:num_weeks_notice).of_type(:integer)
  should have_db_column(:require_crb).of_type(:boolean)
  should have_db_column(:terms).of_type(:text)
  should have_db_column(:volunteers_insured).of_type(:boolean)
  should have_timestamps
  
  should belong_to(:member)
  should have_many(:time_slots)
  
  should validate_presence_of(:member)
  should validate_presence_of(:name)
  
end
