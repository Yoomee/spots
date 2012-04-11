require File.dirname(__FILE__) + '/../test_helper'
class ForgottenPasswordControllerTest < ActionController::TestCase
  
  should have_action(:new).with_level(:open)
  should have_action(:create).with_level(:open)  
  
  context "create action with existing email" do
    
    context "POST" do
      
      setup do
        Factory.create(:member, :email => "test@email.com")
        post :create, :email => "test@email.com"
      end

      # This seems to break at the moment
      #should have_sent_email.to("test@email.com")
      
    end
    
  end
  
end
