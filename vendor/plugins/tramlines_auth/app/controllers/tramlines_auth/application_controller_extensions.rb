module TramlinesAuth::ApplicationControllerExtensions
  
  def self.included(klass)
    klass.before_filter :add_auth_from_session
  end

  private
  def add_auth_from_session
    if logged_in_member && !session[:auth_data].blank?
      if logged_in_member.add_auth_from_session(session[:auth_data])
        flash[:notice] = "Your #{session[:auth_data][:auth_service]} account has been added and you can now use it to log in."
        session[:auth_data] = nil
      end
    end
  end
  
  def refresh_fb_session
    if current_facebook_user.try(:client) && current_facebook_user.client.expired?
      current_facebook_user.client = nil
    end
  end
  
  
end