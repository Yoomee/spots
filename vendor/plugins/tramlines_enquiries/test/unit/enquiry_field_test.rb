require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class EnquiryFieldTest < ActiveSupport::TestCase
  
  should belong_to(:enquiry)
  
end