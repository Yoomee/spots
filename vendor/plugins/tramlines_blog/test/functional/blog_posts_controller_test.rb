require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class BlogPostsControllerTest < ActionController::TestCase

  context "create action" do    

    setup do
      expect_admin
      Member.stubs(:find).returns Factory.build(:member, :id => 456)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
    end

    should "render new template when model is invalid" do
      BlogPost.any_instance.stubs(:valid?).returns(false)
      post :create
      assert_template 'new'
    end
    
    should "redirect when model is valid" do
      BlogPost.any_instance.stubs(:valid?).returns(true)
      post :create
      assert_redirected_to blog_post_url(assigns(:blog_post))
    end

  end
  
  context "destroy action" do

    setup do
      stub_access
      @blog_post = Factory.create(:blog_post)
    end
    
    should "destroy model and redirect to index action" do
      delete :destroy, :id => @blog_post
      assert_redirected_to blog_url(@blog_post.blog)
      assert !BlogPost.exists?(@blog_post.id)
    end

  end

  context "edit action" do

    setup do
      expect_admin
      Member.stubs(:find).returns Factory.build(:member, :id => 456)
      @blog_post = Factory.create(:blog_post)
    end

    should "render edit template" do
      get :edit, :id => @blog_post
      assert_template 'edit'
    end

  end
  
  context "new action" do

    should "render new template" do
      expect_admin
      Member.stubs(:find).returns Factory.build(:member)
      stub_finds(:Blog, Proc.new{Factory.build(:blog, :id => 456)})
      get :new
      assert_template 'new'
    end

  end
  
  context "show action" do

    setup do
      @blog_post = Factory.create(:blog_post)
    end
    
    should "render show template" do
      stub_access
      get :show, :id => @blog_post
      assert_template 'show'
    end

  end
  
  context "update action" do

    setup do
      expect_admin
      Member.stubs(:find).returns Factory.build(:member, :id => 456)
      @blog_post = Factory.create(:blog_post)
    end
    
    should "render edit template when model is invalid" do
      BlogPost.any_instance.stubs(:valid?).returns(false)
      put :update, :id => @blog_post
      assert_template 'edit'
    end
  
    should "redirect when model is valid" do
      BlogPost.any_instance.stubs(:valid?).returns(true)
      put :update, :id => @blog_post
      assert_redirected_to blog_post_url(@blog_post)
    end

  end
  
end
