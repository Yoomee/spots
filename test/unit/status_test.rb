require File.dirname(__FILE__) + '/../test_helper'
class StatusTest < ActiveSupport::TestCase
  
  should belong_to(:member)
  
end
