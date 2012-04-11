require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class EnquiriesControllerTest < ActionController::TestCase
  
  should have_action(:destroy).with_level(:admin_only)
  should have_action(:index).with_level(:admin_only)
  should have_action(:show).with_level(:admin_only)

  context "create action" do    
    
    setup do
      Page.stubs(:find).returns Factory.build(:page)
      Page.stubs(:find).with {|*args| args.first == :all}.returns [Factory.build(:page)]
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      stub_access
    end
    
    should "redirect when model is valid" do
      Enquiry.any_instance.stubs(:valid?).returns(true)
      post :create, :enquiry => {:form_name => 'sample'}
      assert_redirected_to root_url
    end
  
    should "render new template when model is invalid" do
      Enquiry.any_instance.stubs(:valid?).returns false
      post :create, :enquiry => {:form_name => 'sample'}
      assert_template 'new'
    end
    
  end

  context "destroy action" do

    setup do
      stub_access
      @enquiry = Factory.create(:enquiry)
    end
    
    should "destroy model and redirect to index action" do
      delete :destroy, :id => @enquiry
      assert_redirected_to enquiries_url
      assert !Enquiry.exists?(@enquiry.id)
    end

  end

  context "index action" do

    setup do
      stub_access
      stub_finds(Section)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end

    should "render index template" do
      get :index
      assert_template 'index'
    end

  end
  
  context "new action" do
    
    should "render new template" do
      stub_access
      Page.stubs(:find).returns Factory.build(:page)
      Page.stubs(:find).with {|*args| args.first == :all}.returns [Factory.build(:page)]
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      get :new, :id => 'sample'
      assert_template 'new'
    end
    
  end
  
  context "show action" do

    setup do
      stub_access
      @enquiry = Factory.create(:enquiry)
      stub_finds(Section)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    should "render show template" do
      get :show, :id => @enquiry
      assert_template 'show'
    end

  end
  
end
