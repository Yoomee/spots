require File.dirname(__FILE__) + '/../../../../test/test_helper'

class TramlinesWallsTest < ActiveSupport::TestCase

  context "ActiveRecord::Base" do
    
    should "have a has_wall class method" do
      assert_respond_to ActiveRecord::Base, :has_wall
    end
    
  end

end
