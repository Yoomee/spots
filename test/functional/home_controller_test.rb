require File.dirname(__FILE__) + '/../test_helper'
class HomeControllerTest < ActionController::TestCase
  
  should have_action(:index).with_level(:open)
  
  context "all controller/action views on call to *_proc where a parameter is not passed" do
    
    setup do
      stub_finds(Section)
      stub_finds(:BlogPost)
      get :index
      @prc = members_proc
    end
    
    should "give the same result calling the proc with :path as calling *_path" do
      assert_equal members_path, @prc.call(:path)
    end
    
    should "give the same result calling the proc with :path_hash as calling hash_for_*_path" do
      assert_equal hash_for_members_path, @prc.call(:path_hash)
    end
    
    should "give the same result calling the proc with :url as calling *_url" do
      assert_equal members_url, @prc.call(:url)
    end
    
    should "give the same result calling the proc with :url_hash as calling hash_for_*_url" do
      assert_equal hash_for_members_url, @prc.call(:url_hash)
    end
    
  end
  
  context "all controller/action views on call to *_proc where a parameter is passed" do
    
    setup do
      Section.stubs(:first).returns Factory.build(:section)
      @member = Factory.create(:member)
      stub_finds(Section, Factory.build(:section, :id => 123))
      stub_finds(:BlogPost)
      get :index
      @prc = member_proc(@member)
    end
    
    should "give the same result calling the proc with :path as calling *_path" do
      assert_equal member_path(@member), @prc.call(:path)
    end
    
    should "give the same result calling the proc with :path_hash as calling hash_for_*_path" do
      assert_equal hash_for_member_path(:id => @member), @prc.call(:path_hash)
    end
    
    should "give the same result calling the proc with :url as calling *_url" do
      assert_equal member_url(@member), @prc.call(:url)
    end
    
    should "give the same result calling the proc with :url_hash as calling hash_for_*_url" do
      assert_equal hash_for_member_url(:id => @member), @prc.call(:url_hash)
    end
    
  end

  context "on GET to index" do
    
    setup do
      Section.stubs(:first).returns Factory.build(:section)
      @controller.stubs(:view_exists?).returns true
      stub_finds(Section, Factory.build(:section, :id => 123))
      stub_finds(:BlogPost)
      # @controller.expects(:view_exists?).with(HomeController::HOLDING_VIEW).returns true
    end
    
    should "render holding view if it exists and member is not logged in" do
      @controller.request.expects(:path).returns '/'
      @controller.stubs(:render).returns true
      @controller.expects(:render).with(:template => HomeController::HOLDING_VIEW, :layout => false).returns true
      get :index
      assert assigns['is_home']
    end

    should "render index if holding view exists and member is logged in" do
      logged_in_member = expect_logged_in_member
      Member.stubs(:find).returns logged_in_member
      Member.stubs(:find).with {|*args| args.first == :all}.returns [logged_in_member]
      get :index
      assert assigns['is_home']
    end

    should "render index if holding view exists and request path is /logged-out" do
      @controller.request.expects(:path).at_least_once.returns '/logged-out'
      get :index
      assert assigns['is_home']
    end
      
  end
  
end
