require File.dirname(__FILE__) + '/../test_helper'
class MailsControllerTest < ActionController::TestCase
  
  context "read action" do
    
    setup do
      @mail = Factory.build(:sent_mail)
      Mail.stubs(:find).returns @mail
    end
    
    context "GET" do
      
      setup do
        get :read, :id => 123
      end
      
      before_should "find the mail" do
        Mail.expects(:find).with('123').returns @mail
      end
      
      should "set the status of the mail to read" do
        assert @mail.read?
      end
      
    end
    
  end
  
end