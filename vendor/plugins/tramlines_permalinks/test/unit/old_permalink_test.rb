require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class OldPermalinkTest < ActiveSupport::TestCase
  
  should have_db_column(:name).of_type(:string)
  should have_db_column(:model_type).of_type(:string)
  should have_db_column(:model_id).of_type(:integer)
  should have_timestamps
  
  should belong_to(:model)  
  
  should validate_presence_of(:name)
  should validate_presence_of(:model)
  
end