require File.dirname(__FILE__) + '/../test_helper'
class PhotosControllerTest < ActionController::TestCase

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
    end

    should "render new template when model is invalid" do
      Photo.any_instance.stubs(:valid?).returns(false)
      stub_finds(Section)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      post :create
      assert_template 'new'
    end
    
    should "redirect when model is valid" do
      Photo.any_instance.stubs(:valid?).returns(true)
      Photo.any_instance.stubs(:resize_down).returns true
      post :create
      assert_redirected_to photo_url(assigns(:photo))
    end

  end
  
  context "destroy action" do

    setup do
      stub_access
      @photo = Factory.create(:photo)
    end
    
    should "destroy model and redirect to index action" do
      delete :destroy, :id => @photo
      assert_redirected_to photos_url
      assert !Photo.exists?(@photo.id)
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
  
  context "edit action" do

    setup do
      stub_access
      @photo = Factory.create(:photo)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end

    should "render edit template" do
      get :edit, :id => @photo
      assert_template 'edit'
    end

  end
  
  context "show action" do

    setup do
      @photo = Factory.create(:photo)
      might_expect_logged_in_member      
      stub_finds(Section)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    should "render show template" do
      get :show, :id => @photo
      assert_template 'show'
    end

  end
  
  context "update action" do

    setup do
      stub_access      
      stub_finds(Section)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      @photo = Factory.create(:photo)
    end
    
    should "render edit template when model is invalid" do
      Photo.any_instance.stubs(:valid?).returns(false)
      put :update, :id => @photo
      assert_template 'edit'
    end
  
    should "redirect when model is valid" do
      Photo.any_instance.stubs(:valid?).returns(true)
      put :update, :id => @photo
      assert_redirected_to photo_url(@photo)
    end

  end
  
end
