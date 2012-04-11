require File.dirname(__FILE__) + '/../test_helper'
class PermissionsTest < ActionController::TestCase
  
  tests HomeController
  
  context "admin_only action" do
  
    setup do
      HomeController.admin_only(:index)
    end
  
    should "allow admins" do
      member = Factory.build(:admin_member)
      assert HomeController::allowed_to?({:action => 'index'}, member)
    end

    should "not allow logged-in members" do
      member = Factory.build(:member, :is_admin => false)
      assert !HomeController::allowed_to?({:action => 'index'}, member)
    end

    should "not allow logged-out members" do
      assert !HomeController::allowed_to?({:action => 'index'}, nil)
    end
  
  end

  context "member_only action" do
  
    setup do
      HomeController.member_only(:index)
    end
  
    should "allow admins" do
      member = Factory.build(:member, :is_admin => true)
      assert HomeController::allowed_to?({:action => 'index'}, member)
    end
  
    should "allow logged-in members" do
      member = Factory.build(:member, :is_admin => false)
      assert HomeController::allowed_to?({:action => 'index'}, member)
    end
  
    should "not allow logged-out members" do
      assert !HomeController::allowed_to?({:action => 'index'}, nil)
    end
  
  end

  context "open action" do
  
    setup do
      HomeController.open_action(:index)
    end
  
    should "allow admins" do
      member = Factory.build(:member, :is_admin => true)
      assert HomeController::allowed_to?({:action => 'index'}, member)
    end
  
    should "allow logged-in members" do
      member = Factory.build(:member, :is_admin => false)
      assert HomeController::allowed_to?({:action => 'index'}, member)
    end
  
    should "allow logged-out members" do
      assert HomeController::allowed_to?({:action => 'index'}, nil)
    end
  
  end
  
  context "with member_only default_permission_level" do
  
    setup do
      @default_permission_level = ApplicationController.default_permission_level
      ApplicationController.set_default_permission_level(:member_only)
    end
  
    teardown do
      ApplicationController.set_default_permission_level(@default_permission_level)
    end
    
    context "an action set as open_action" do
    
      setup do
        HomeController.open_action(:index)
      end
    
      should "allow admins" do
        member = Factory.build(:member, :is_admin => true)
        assert HomeController::allowed_to?({:action => 'index'}, member)
      end
    
      should "allow logged-in members" do
        member = Factory.build(:member, :is_admin => false)
        assert HomeController::allowed_to?({:action => 'index'}, member)
      end
    
      should "allow logged-out members" do
        assert HomeController::allowed_to?({:action => 'index'}, nil)
      end
    
    end
    
    context "custom_permission action" do

      setup do
        HomeController.custom_permission(:index) do |url_options, member|
          member.nil? ? false : true
        end
      end

      should "allow correct members" do
        member = Factory.build(:member)
        assert HomeController::allowed_to?({:action => 'index'}, member)
      end

      should "not allow correct members" do
        assert !HomeController::allowed_to?({:action => 'index'}, nil)
      end

    end
    
    context "an action without a permission set" do
    
      setup do
        HomeController.send(:clear_permission_levels, [:index])
      end
    
      should "allow admins" do
        member = Factory.build(:member, :is_admin => true)
        assert HomeController::allowed_to?({:action => 'index'}, member)
      end
    
      should "allow logged-in members" do
        member = Factory.build(:member, :is_admin => false)
        assert HomeController::allowed_to?({:action => 'index'}, member)
      end
    
      should "not allow logged-out members" do
        assert !HomeController::allowed_to?({:action => 'index'}, nil)
      end
    
    end
    
  end
  
end
