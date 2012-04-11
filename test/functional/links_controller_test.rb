require File.dirname(__FILE__) + '/../test_helper'
class LinksControllerTest < ActionController::TestCase

  should have_action(:create).with_level(:member_only)
  should have_action(:destroy).with_level(:owner_only)
  should have_action(:edit).with_level(:owner_only)
  should have_action(:new).with_level(:member_only)
  should have_action(:update).with_level(:owner_only)
  
  context "create action" do    

    setup do
      logged_in_member = expect_logged_in_member
      Member.stubs(:find).returns logged_in_member
      Member.stubs(:find).with {|*args| args.first == :all}.returns [logged_in_member]
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end

    should "render new template when model is invalid" do
      Link.any_instance.stubs(:valid?).returns(false)
      post :create
      assert_template 'new'
    end
    
    should "redirect when model is valid" do
      Link.any_instance.stubs(:valid?).returns(true)
      post :create
      assert_redirected_to link_url(assigns(:link))
    end

  end
  
  context "destroy action" do

    setup do
      stub_access
      @link = Factory.create(:link)
    end
    
    should "destroy model and redirect to index action" do
      delete :destroy, :id => @link
      assert_redirected_to links_url
      assert !Link.exists?(@link.id)
    end

  end

  context "edit action" do

    setup do
      stub_access
      @link = Factory.create(:link)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end

    should "render edit template" do
      get :edit, :id => @link
      assert_template 'edit'
    end

  end
  
  context "index action" do    

    should "render index template" do
      might_expect_logged_in_member
      stub_finds(Section)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      get :index
      assert_template 'index'
    end

  end
  
  context "new action" do

    should "render new template" do
      logged_in_member = expect_logged_in_member
      Member.stubs(:find).returns logged_in_member
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      get :new
      assert_template 'new'
    end

  end
  
  context "show action" do

    setup do
      @link = Factory.create(:link)
      might_expect_logged_in_member      
      stub_finds(Section)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    should "render show template" do
      get :show, :id => @link
      assert_template 'show'
    end

  end
  
  context "update action" do

    setup do
      stub_access
      @link = Factory.create(:link)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    should "render edit template when model is invalid" do
      Link.any_instance.stubs(:valid?).returns(false)
      put :update, :id => @link
      assert_template 'edit'
    end
  
    should "redirect when model is valid" do
      Link.any_instance.stubs(:valid?).returns(true)
      put :update, :id => @link
      assert_redirected_to link_url(@link)
    end

  end
  
end
