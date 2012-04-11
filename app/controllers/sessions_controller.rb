class SessionsController < ApplicationController
  
  open_actions :new, :create, :set_login_waypoint
  yoomee_only :morph
  
  open_action :destroy
  
  skip_before_filter :clear_login_redirect, :clear_login_redirect_message, :only => %w{create new}
  skip_before_filter :force_password_change, :only => %w{destroy}
  before_filter :process_login, :only => "create"
  
  skip_before_filter :verify_authenticity_token, :only => :destroy
  
  def create
    if @logged_in_member
      login_member!(@logged_in_member)
    else
      #flash[:error] = "Login details not found. Please try again."
      set_login_redirect_message("Login details not found. Please try again.")
      render :action => 'new'
    end
  end
  
  def destroy
    if logged_in?
      logout_member!
    else
      render_404
    end
  end
  
  def morph
    member = Member.find(params[:login_member_id])
    params[:redirect_to] = "/"
    login_member!(member, :super => true)
  end

  def new
  end
  
  #sets login_waypoint, used with link_to_login_fancybox
  def set_login_waypoint
    session[:login_waypoint] = params[:url]
    render :text => 'true'
  end
  
  def set_waypoint
    session[:waypoint] = params[:waypoint]
    render :text => session[:waypoint]
  end
  
  private
  def process_login
    @logged_in_member = Member.authenticate(params[:login_email_or_username], params[:login_password])
  end
  
end
