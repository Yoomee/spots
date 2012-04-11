require File.dirname(__FILE__) + '/../test_helper'
class SuperControllerTest < ActionController::TestCase

  should have_action(:index).with_level(:yoomee_only)
  
  context "index action" do
  
    should "allow yoomee members" do
      member = Factory.build(:yoomee_member)
      assert SuperController::allowed_to?({:action => 'index'}, member)
    end
    
    should "not allow admin members" do
      member = Factory.build(:admin_member)
      assert !SuperController::allowed_to?({:action => 'index'}, member)
    end
    
    should "not allow other members" do
      member = Factory.build(:member)
      assert !SuperController::allowed_to?({:action => 'index'}, member)
    end

    should "not allow logged-out members" do
      assert !SuperController::allowed_to?({:action => 'index'}, nil)
    end
  
  end
end
