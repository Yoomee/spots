require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class BlogPostTest < ActiveSupport::TestCase
  
  should belong_to(:member)
  should have_and_belong_to_many(:blog_post_categories)
  
  should validate_presence_of(:text)
  should validate_presence_of(:title)

  context "an instance" do 
    
    setup do
      @blog_post = Factory.build(:blog_post)
    end
    
    should 'return the member on call to author' do
      assert_equal @blog_post.member, @blog_post.author
    end
    
    should "set the member on call to author=" do
      member = Factory.build(:member)
      @blog_post.author = member
      assert_equal member, @blog_post.member
    end
    
  end
  
  context "class on call to by" do
    
    setup do
      @member = Factory.create(:member)
      @by_post = Factory.create(:blog_post, :member => @member)
      @not_by_post = Factory.create(:blog_post)
      @results = BlogPost.by(@member)
    end
    
    should "not return a post not by the member" do
      assert_does_not_contain @results, @not_by_post
    end
    
    should "return a post by the member" do
      assert_contains @results, @by_post
    end
    
  end
  
end
