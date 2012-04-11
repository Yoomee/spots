require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class SnippetTest < ActiveSupport::TestCase
  
  should belong_to(:item)
  
end