require File.dirname(__FILE__) + '/../test_helper'
class NewsFeedItemTest < ActiveSupport::TestCase
  
  should belong_to(:attachable)
  
end