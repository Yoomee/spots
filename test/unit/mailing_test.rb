require File.dirname(__FILE__) + '/../test_helper'
class MailingTest < ActiveSupport::TestCase
  
  should have_many(:mails)
  
end