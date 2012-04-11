module TramlinesAuth
  
  def self.included(klass)
    ApplicationController.send(:include, TramlinesAuth::ApplicationControllerExtensions)
    SessionsController.send(:include, TramlinesAuth::SessionsControllerExtensions)
    MembersController.send(:include, TramlinesAuth::MembersControllerExtensions)
    ImageHelper.send(:include, TramlinesAuth::ImageHelperExtensions)
    Member.send(:include, TramlinesAuth::MemberExtensions)
  end
  
end
