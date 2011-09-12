require File.dirname(__FILE__) + '/../../../test/test_helper'
class DocumentTest < ActiveSupport::TestCase
  
  should belong_to(:activity)
  
end