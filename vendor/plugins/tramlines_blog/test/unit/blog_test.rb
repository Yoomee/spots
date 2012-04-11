require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class BlogTest < ActiveSupport::TestCase
  
  should belong_to(:member)
  should have_many(:blog_posts)
  
  should validate_presence_of(:name)

  context "an instance" do
    
    setup do
      @blog = Factory.build(:blog)
    end
    
    should "return the blog posts by an author on call to posts_by" do
      member = Factory.build(:member)
      posts_mock = mock
      @blog.expects(:posts).returns posts_mock
      @blog_posts = [Factory.build(:blog_post), Factory.build(:blog_post)]
      posts_mock.expects(:by).with(member).returns @blog_posts
      assert_equal @blog_posts, @blog.posts_by(member)
    end
    
    should "return the number of blog posts by an author on call to number_of_posts_by" do
      member = Factory.build(:member)
      posts_by_mock = mock
      @blog.expects(:posts_by).with(member).returns posts_by_mock
      posts_by_mock.expects(:size).returns 5
      assert_equal 5, @blog.number_of_posts_by(member)
    end
    
  end
  
  context "on call to authors" do
    
    should "not return duplicate authors" do
      blog = Factory.create(:blog, :posts => [])
      blog_post1 = Factory.create(:blog_post, :blog => blog)
      blog_post2 = Factory.create(:blog_post, :blog => blog, :member => blog_post1.author)
      assert_equal [blog_post1.author], blog.authors
    end

    should "return an array of blog authors when there are blog posts" do
      blog = Factory.create(:blog, :posts => [])
      blog_post1 = Factory.create(:blog_post, :blog => blog)
      blog_post2 = Factory.create(:blog_post, :blog => blog)
      assert_equal [blog_post1.author, blog_post2.author], blog.authors
    end
    
    should "return an empty array when there are no blog posts" do
      blog = Factory.create(:blog, :posts => [])
      assert_equal [], blog.authors
    end
    
  end
  
end
