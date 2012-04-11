require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class MemberTest < ActiveSupport::TestCase
  
  should have_db_column(:fb_user_id).of_type(:string)
  should have_db_column(:linked_in_user_id).of_type(:string)
  
  context "on call to force_password_change?" do
    
    setup do
      @member = Factory.build(:member)
      @member.password_generated = true
    end

    should "return false if member has fb_user_id" do
      @member.fb_user_id = "123"
      assert !@member.force_password_change?
    end

    should "return false if member has linked_in_user_id" do
      @member.linked_in_user_id = "123"
      assert !@member.force_password_change?
    end
    
    should "return true if member has no fb_user_id and no linked_in_user_id" do
      assert @member.force_password_change?
    end
    
  end
  
end
