require File.dirname(__FILE__) + '/../test_helper'
class VideosControllerTest < ActionController::TestCase

  should have_action(:create).with_default_level(:member_only)
  should have_action(:destroy).with_level(:owner_only)
  should have_action(:edit).with_level(:owner_only)
  should have_action(:new).with_default_level(:member_only)
  should have_action(:update).with_level(:owner_only)
  
  context "create action" do    

    setup do
      logged_in_member = expect_logged_in_member
      stub_access
      Member.stubs(:find).returns logged_in_member
      Member.stubs(:find).with {|*args| args.first == :all}.returns [logged_in_member]
    end

    should "redirect when model is valid" do
      Video.any_instance.stubs(:valid?).returns(true)
      post :create
      assert_redirected_to video_url(assigns(:video))
    end

    should "render new template when model is invalid" do
      Video.any_instance.stubs(:valid?).returns(false)
      stub_finds(Section, Factory.build(:section, :id => 123))
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      post :create
      assert_template 'new'
    end
    
  end
  
  context "destroy action" do

    setup do
      stub_access
      @video = Factory.create(:video)
    end
    
    should "destroy model and redirect to index action" do
      delete :destroy, :id => @video
      assert_redirected_to videos_url
      assert !Video.exists?(@video.id)
    end

  end

  context "edit action" do

    setup do
      stub_access
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      @video = Factory.create(:video)
    end

    should "render edit template" do
      get :edit, :id => @video
      assert_template 'edit'
    end

  end
  
  context "index action" do 

    should "render index template" do
      might_expect_logged_in_member
      stub_finds(Section, Factory.build(:section, :id => 123))
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      get :index
      assert_template 'index'
    end

  end
  
  context "new action" do

    should "render new template" do
      stub_access
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      get :new
      assert_template 'new'
    end

  end
  
  context "show action" do

    setup do
      @video = Factory.create(:video, :created_at => Time.now)
      stub_finds(Section, Factory.build(:section, :id => 123))
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      might_expect_logged_in_member
    end
    
    should "render show template" do
      get :show, :id => @video
      assert_template 'show'
    end

  end
  
  context "update action" do

    setup do
      stub_access
      stub_finds(Section, Factory.build(:section, :id => 123))
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      @video = Factory.create(:video)
    end
    
    should "redirect when model is valid" do
      Video.any_instance.stubs(:valid?).returns(true)
      put :update, :id => @video
      assert_redirected_to video_url(@video)
    end

    should "render edit template when model is invalid" do
      Video.any_instance.stubs(:valid?).returns(false)
      put :update, :id => @video
      assert_template 'edit'
    end
  
  end
  
end
