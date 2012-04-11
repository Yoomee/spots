require File.dirname(__FILE__) + '/../../../test/test_helper'
class TextHelperTest < ActionView::TestCase
  
  context "on call to auto_link" do
    
    should "auto link email addresses" do
      assert_equal "This is a link to <a href=\"mailto:si@yoomee.com\">si@yoomee.com</a>", auto_link("This is a link to si@yoomee.com")
    end
    
    should "not auto link email addresses in a tag" do
      assert_equal "This is a link to <a href=\"mailto:si@yoomee.com\">Si</a>", auto_link("This is a link to <a href=\"mailto:si@yoomee.com\">Si</a>")
    end
    
  end
  
end