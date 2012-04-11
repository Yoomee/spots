require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class BlogsControllerTest < ActionController::TestCase

  context "create action" do    

    setup do
      stub_access
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end

    should "render new template when model is invalid" do
      Blog.any_instance.stubs(:valid?).returns(false)
      post :create
      assert_template 'new'
    end
    
    should "redirect when model is valid" do
      Blog.any_instance.stubs(:valid?).returns(true)
      post :create
      assert_redirected_to blog_url(assigns(:blog))
    end

  end
  
  context "destroy action" do

    setup do
      stub_access
      @blog = Factory.create(:blog)
    end
    
    should "destroy model and redirect to index action" do
      delete :destroy, :id => @blog
      assert_redirected_to blogs_url
      assert !Blog.exists?(@blog.id)
    end

  end

  context "edit action" do

    setup do
      stub_access
      @blog = Factory.create(:blog)
    end

    should "render edit template" do
      get :edit, :id => @blog
      assert_template 'edit'
    end

  end
  
  context "index action" do

    should "render index template" do
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      stub_access
      get :index
      assert_template 'index'
    end

  end
  
  context "new action" do

    should "render new template" do
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      stub_access
      get :new
      assert_template 'new'
    end

  end
  
  context "show action" do

    setup do
      @blog = Factory.create(:blog)
    end
    
    should "render show template" do
      stub_access
      get :show, :id => @blog
      assert_template 'show'
    end

  end
  
  context "update action" do

    setup do
      stub_access      
      @blog = Factory.create(:blog)
    end
    
    should "render edit template when model is invalid" do
      Blog.any_instance.stubs(:valid?).returns(false)
      put :update, :id => @blog
      assert_template 'edit'
    end
  
    should "redirect when model is valid" do
      Blog.any_instance.stubs(:valid?).returns(true)
      put :update, :id => @blog
      assert_redirected_to blog_url(@blog)
    end

  end
  
end
