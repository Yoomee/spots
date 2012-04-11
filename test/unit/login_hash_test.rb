require File.dirname(__FILE__) + '/../test_helper'
class LoginHashTest < ActiveSupport::TestCase
  
  should have_db_column(:member_id).of_type(:integer)
  should have_db_column(:salt).of_type(:string)
  should have_db_column(:long_hash).of_type(:string)
  should have_db_column(:expire_at).of_type(:datetime)
  
  should belong_to(:member)
  
  should validate_presence_of(:member_id)
  should validate_presence_of(:salt)
  should validate_presence_of(:long_hash)    
  
end