require File.dirname(__FILE__) + '/../../../test/test_helper'
class MemberTest < ActiveSupport::TestCase
  
  should have_many(:organisations).dependent(:nullify)
  should have_many(:time_slot_bookings).dependent(:destroy)
  
end