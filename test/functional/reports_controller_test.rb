require File.dirname(__FILE__) + '/../test_helper'
class ReportsControllerTest < ActionController::TestCase
  
  should have_action(:create).with_level(:admin_only)
  should have_action(:new).with_level(:admin_only)
  
  context "new action" do
    
  end
  
end
