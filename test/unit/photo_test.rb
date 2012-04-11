require File.dirname(__FILE__) + '/../test_helper'
class PhotoTest < ActiveSupport::TestCase
  
  should belong_to(:attachable)  
  should belong_to(:member)
  should belong_to(:photo_album)
  
  should_delegate(:url, :to => :image)

  should validate_presence_of(:member)
  
  context "a valid instance" do
    
    setup do
      @photo = Factory.build(:photo)
    end
    
    should "be_valid" do
      assert_valid @photo
    end
    
  end
  
  context "on call to name" do
    
    should "return database value if not blank" do
      @photo = Factory.build(:photo, :name => "New Photo")
      assert_equal @photo.name, "New Photo"
    end
    
    should "return 'Untitled Photo' if blank" do
      @photo = Factory.build(:photo, :name => '')
      assert_equal @photo.name, "Untitled Photo"
    end
    
  end
  
end
