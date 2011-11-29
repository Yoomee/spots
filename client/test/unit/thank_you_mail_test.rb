require File.dirname(__FILE__) + '/../../../test/test_helper'
class ThankYouMailTest < ActiveSupport::TestCase
  
  context "an instance" do
    
    setup do
      @thank_you_mail = ThankYouMail.new
    end
    
    should "have a subject method" do
      assert_respond_to @thank_you_mail, :subject
    end
    
  end
  
end