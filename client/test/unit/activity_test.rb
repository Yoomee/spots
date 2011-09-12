require File.dirname(__FILE__) + '/../../../test/test_helper'
class ActivityTest < ActiveSupport::TestCase
  
  should have_db_column(:name).of_type(:string)
  should have_db_column(:description).of_type(:text)
  should have_db_column(:image_uid).of_type(:string)
  should have_db_column(:activity_type).of_type(:string)
  should have_db_column(:weight).of_type(:integer).with_options(:default => 0)
  should have_timestamps

  should have_many(:documents).dependent(:destroy)
  should have_many(:time_slots).dependent(:destroy)
    
  should validate_presence_of(:name)
  
end