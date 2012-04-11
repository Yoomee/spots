require File.dirname(__FILE__) + '/../test_helper'
class MailTest < ActiveSupport::TestCase
  
  should belong_to(:mailing)
  should belong_to(:recipient)
  should have_db_column(:html_body)
  should have_db_column(:plain_body)
  should have_db_column(:subject)
  should validate_presence_of(:from)
  should validate_presence_of(:recipient)
  should validate_presence_of(:subject)
  
  
  context "a valid instance" do
    
    setup do
      @mail = Factory.build(:mail)
    end
    
    should "save" do
      assert_save @mail
    end
    
    should "have status 'not_sent'" do
      assert @mail.not_sent?
    end
    
  end
  
  context "a sent instance" do
    
    setup do
      @mail = Factory.create(:mail)
      @mail.send_email!
      @mail.reload
    end
    
    should "have status 'sent'" do
      assert @mail.sent?
    end
    
  end
  
end
