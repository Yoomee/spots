require File.dirname(__FILE__) + '/../test_helper'
class VideoTest < ActiveSupport::TestCase
  
  should belong_to(:attachable)
  should belong_to(:member)
  
  should validate_presence_of(:member)
  should validate_presence_of(:url)
  
  context "a valid instance" do
    
    setup do
      @video = Factory.build(:video)
    end
    
    should "be_valid" do
      assert_valid @video
    end
    
  end
  
  context "on call to name" do
    
    should "return database value if not blank" do
      @video = Factory.build(:video, :name => "New Video")
      assert_equal @video.name, "New Video"
    end
    
    should "return 'Untitled Video' if blank" do
      @video = Factory.build(:video, :name => '')
      assert_equal @video.name, "Untitled Video"
    end
    
  end
  
  context "on call to url=" do
    
    should "add 'http://' prefix if it is missing" do
      @video = Factory.build(:video, :url => "www.vimeo.com/123")
      assert_equal @video.url, "http://www.vimeo.com/123"
    end
    
    should "not add 'http://' when it is already present" do
      @video = Factory.build(:video, :url => "http://www.vimeo.com/123")
      assert_equal @video.url, "http://www.vimeo.com/123"
    end
    
  end
  
end