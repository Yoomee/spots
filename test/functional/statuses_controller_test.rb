require File.dirname(__FILE__) + '/../test_helper'
class StatusesControllerTest < ActionController::TestCase

  should have_action(:create).with_level(:member_only)
  should have_action(:destroy).with_level(:owner_only)
  
  context "show action" do
    
    setup do
      @status = Factory.create(:status)
      might_expect_logged_in_member
      stub_finds(Section)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    should "render show template" do
      get :show, :id => @status
      assert_template 'show'
    end
    
  end
  
  context "destroy action" do
    
    setup do
      stub_access
      @status = Factory.create(:status)
    end
    
    should "destroy model" do
      delete :destroy, :id => @status
      assert !Status.exists?(@status.id)
    end    
    
  end
  
end
