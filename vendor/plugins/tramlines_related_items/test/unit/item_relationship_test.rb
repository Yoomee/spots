require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class ItemRelationshipTest < ActiveSupport::TestCase
  
  should belong_to(:item)
  should belong_to(:related_item)
  
end