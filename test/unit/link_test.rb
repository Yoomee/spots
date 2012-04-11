require File.dirname(__FILE__) + '/../test_helper'
class LinkTest < ActiveSupport::TestCase
  
  should belong_to(:attachable)
  should belong_to(:member)
  
  context "a valid instance" do
    
    setup do
      @link = Factory.build(:link)
    end
    
    should "be_valid" do
      assert_valid @link
    end
    
  end
  
  context "on call to name" do
    
    should "return database value if not blank" do
      @link = Factory.build(:link, :name => "New Link")
      assert_equal @link.name, "New Link"
    end
    
    should "return url if blank" do
      @link = Factory.build(:link, :name => '', :url => "http://yoomee.com")
      assert_equal @link.name, "yoomee.com"
    end
    
  end
  
end