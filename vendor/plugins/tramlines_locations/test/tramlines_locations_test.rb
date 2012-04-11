require File.dirname(__FILE__) + '/../../../../test/test_helper'

class TramlinesLocationsTest < ActiveSupport::TestCase

  context "ActiveRecord::Base" do
    
    should "have a has_location class method" do
      assert_respond_to ActiveRecord::Base, :has_location
    end
    
  end

end
