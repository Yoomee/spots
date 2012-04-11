require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class BlogPostCategoriesControllerTest < ActionController::TestCase

  context "create action" do    

    setup do
      stub_access
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end

    should "render new template when model is invalid" do
      BlogPostCategory.any_instance.stubs(:valid?).returns(false)
      post :create
      assert_template 'new'
    end
    
    should "redirect when model is valid" do
      BlogPostCategory.any_instance.stubs(:valid?).returns(true)
      post :create
      assert_redirected_to blog_post_categories_url
    end

  end
  
  context "destroy action" do

    setup do
      stub_access
      @blog_post_category = Factory.create(:blog_post_category)
    end
    
    should "destroy model and redirect to index action" do
      delete :destroy, :id => @blog_post_category
      assert_redirected_to blog_post_categories_url
      assert !BlogPostCategory.exists?(@blog_post_category.id)
    end

  end

  context "edit action" do

    setup do
      stub_access
      @blog_post_category = Factory.create(:blog_post_category)
    end

    should "render edit template" do
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      get :edit, :id => @blog_post_category
      assert_template 'edit'
    end

  end
  
  context "index action" do

    should "render index template" do
      stub_access
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
      stub_access
      @blog_post_category = Factory.create(:blog_post_category)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    should "render show template" do
      get :show, :id => @blog_post_category
      assert_template 'show'
    end

  end
  
  context "update action" do

    setup do
      stub_access      
      @blog_post_category = Factory.create(:blog_post_category)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end
    
    should "render edit template when model is invalid" do
      BlogPostCategory.any_instance.stubs(:valid?).returns(false)
      put :update, :id => @blog_post_category
      assert_template 'edit'
    end
  
    should "redirect when model is valid" do
      BlogPostCategory.any_instance.stubs(:valid?).returns(true)
      put :update, :id => @blog_post_category
      assert_redirected_to blog_post_category_url(@blog_post_category)
    end

  end
  
end
