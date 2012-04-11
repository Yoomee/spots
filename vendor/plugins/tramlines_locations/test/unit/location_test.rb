require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class LocationTest < ActiveSupport::TestCase
  
  should belong_to(:attachable)
  
end