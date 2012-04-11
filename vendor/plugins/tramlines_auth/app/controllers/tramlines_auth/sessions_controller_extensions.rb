module TramlinesAuth::SessionsControllerExtensions
  
  def self.included(klass)
    # klass.skip_before_filter(:verify_authenticity_token, :only => "create_fb")
    klass.before_filter(:delete_session_data, :only => "destroy")
    klass.before_filter :refresh_fb_session, :except => 'destroy'
    klass.open_actions(:auth_create, :auth_failure, :create_fb)
    klass.skip_before_filter :http_basic_authenticate, :only => :create_fb
  end
  
  def auth_create
    auth = request.env["omniauth.auth"]
    if logged_in_member
      logged_in_member.add_omniauth(auth)
      logged_in_member.save!
      render(:text => "<script type='text/javascript'>window.close()</script>")
    else
      @member = Member.find_or_initialize_with_omniauth(auth)
      login_member!(@member, :redirect => false) if !@member.new_record?
      if @member.email.blank?
        session[:auth_data] = nil
        render :template => "sessions/register_email", :layout => 'auth_popup'
      else
        @member.save!
        login_member!(@member, :redirect => false)
        render(:text => "<script type='text/javascript'>window.close()</script>")
      end
    end
  end
  
  def auth_failure
  end
  
  # def create_fb
  #   if current_facebook_user
  #     process_login_fb
  #     login_member!(@logged_in_member)
  #   else
  #     redirect_hash = waypoint || {}
  #     redirect_to redirect_hash.merge(:denied_fb_perms => true)
  #   end
  # end
  
  private
  def delete_session_data
    viewed_splash_pages = session[:viewed_splash_pages]
    reset_session
    session[:viewed_splash_pages] = viewed_splash_pages
  end
  
  def process_login_fb
    @logged_in_member = Member.find_by_fb_user_id(current_facebook_user.id)
    current_facebook_user.fetch
    @logged_in_member = Member.find_or_initialize_by_email(current_facebook_user.email)
    @logged_in_member.update_attributes(:fb_user_id => current_facebook_user.id, :forename => current_facebook_user.first_name, :surname => current_facebook_user.last_name)
  end
  
end
