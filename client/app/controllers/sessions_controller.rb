SessionsController.class_eval do
  
  skip_before_filter :redirect_to_organisation_terms, :only => %w{destroy}

  def create_fb
    if request.xhr?
      if current_facebook_user
        process_login_fb
        session[:logged_in_member_id] = @logged_in_member.id
        render :text => "success"
      else
        render :text => "failure"
      end
    else
      if current_facebook_user
        process_login_fb
        login_member!(@logged_in_member)
      else
        redirect_hash = waypoint || {}
        redirect_to redirect_hash.merge(:denied_fb_perms => true)
      end
    end
  end

  private
  def process_login_fb
    @logged_in_member = Member.find_by_fb_user_id(current_facebook_user.id)
    if @logged_in_member.nil?
      current_facebook_user.fetch
      @logged_in_member = Member.find_or_initialize_by_email(current_facebook_user.email)
      @logged_in_member.update_attributes(:fb_user_id => current_facebook_user.id, :forename => current_facebook_user.first_name, :surname => current_facebook_user.last_name)
    end
  end

end