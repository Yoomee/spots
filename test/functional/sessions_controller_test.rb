require File.dirname(__FILE__) + '/../test_helper'
class SessionsControllerTest < ActionController::TestCase

  should have_action(:create).with_level(:open)
  should have_action(:destroy).with_level(:open)
  should have_action(:new).with_level(:open)
  should have_action(:set_login_waypoint).with_level(:open)
  
  context "on DELETE to destroy" do
    
    setup do
      session[:logged_in_member_id] = 123
      @controller.expects(:find_logged_in_member).returns Factory.build(:member)
      @controller.stubs(:gate_keep).returns true
      delete :destroy
    end
    
    should redirect_to('the homepage') {root_url}
    
    should "delete the member from the session" do
      assert_nil session[:logged_in_member_id]
    end
    
  end
  
  context "on GET to new" do
    
    setup do
      @controller.stubs(:gate_keep).returns true
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      get :new
    end
    
    should render_template(:new)
    
  end
  
  context "on POST to create when the details are invalid" do
    
    setup do
      @controller.stubs(:gate_keep).returns true
      Member.expects(:authenticate).with('test@test.com', 'pa55w0rd').returns nil
      stub_finds(Section)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      post :create, :login_email_or_username => 'test@test.com', :login_password => 'pa55w0rd'
    end
    
    should render_template(:new)
    
  end

  context_unless_plugin(:tramlines_member_verifications, "on POST to create when the details are valid") do
    
    setup do
      @controller.stubs(:gate_keep).returns true
      @member = Factory.build(:member, :id => 123)
      Member.expects(:authenticate).with('test@test.com', 'pa55w0rd').returns @member
      post :create, :login_email_or_username => 'test@test.com', :login_password => 'pa55w0rd'
    end
    
    should redirect_to('the homepage') {root_url}

    should "assign the member id to the session" do
      assert_equal 123, session[:logged_in_member_id]
    end
    
  end

end
