require File.dirname(__FILE__) + '/../../../../../test/test_helper'
class WallTest < ActiveSupport::TestCase
  
  should belong_to(:attachable)
  should have_many(:members_who_posted)
  should have_many(:wall_posts)
  
end
