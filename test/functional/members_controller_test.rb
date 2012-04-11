require File.dirname(__FILE__) + '/../test_helper'
class MembersControllerTest < ActionController::TestCase
  
  should have_action(:destroy).with_default_level(:admin_only)
  should have_action(:edit).with_level(:owner_only)
  should have_action(:show).with_default_level(:member_only)
  should have_action(:update).with_level(:owner_only)

  context "destroy action" do
    
    setup do
      @member = Factory.build(:member, :id => 123)
      Member.stubs(:find).returns @member
      @member.stubs(:destroy).returns true
    end
    
    context "DELETE" do
      
      setup do
        stub_access
        delete :destroy, :id => 123
      end
      
      before_should "find the member" do
        Member.expects(:find).with('123').returns @member
      end
      
      before_should "destroy the member" do
        @member.expects(:destroy).returns true
      end
      
      should respond_with(:redirect)
      
    end
    
  end
  
  context "on GET to show" do
    
    setup do
      stub_access
      @member = Factory.build(:member, :id => 123)
      Member.stubs(:find).returns @member
      Member.stubs(:find).with {|*args| args.first == :all}.returns [@member]
      Member.expects(:find).with('123').returns @member
      stub_finds(Section)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      get :show, :id => 123
    end
    
    should assign_to(:member).with {@member}
    should render_template(:show)
    
  end
  
end
