# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  ExceptionNotifier.exception_recipients = "developers@yoomee.com"
  ExceptionNotifier.sender_address = "exception@#{APP_CONFIG["site_url"].gsub(/https?:\/\/(www.)?/,'')}"
  ExceptionNotifier.email_prefix = APP_CONFIG['site_name'] + ': '

  extend ActiveSupport::Memoizable

  include ApplicationControllerConcerns::Permissions
  include ApplicationControllerConcerns::Tabs
  include ApplicationControllerConcerns::Twitter  
  include ApplicationControllerConcerns::Waypoints
  include ApplicationControllerConcerns::Preprocess
  include ApplicationControllerConcerns::HelperMethods  
  include ApplicationControllerConcerns::HttpBasicAuthentication
  
  include ExceptionNotifiable

  include ProvidesAdminItems
  
  # Initialize permissions data for controller
  
  helper :all # include all helpers, all the time

  # prepend_view_path "#{RAILS_ROOT}/client/app/views"
  arrange_view_paths

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  before_filter :change_htm_to_html
  before_filter :force_password_change
  
  private
  def force_password_change
    if @logged_in_member && @logged_in_member.force_password_change?
      redirect_to change_password_member_path(@logged_in_member)
    end
  end
  
  def change_htm_to_html
    request.format = :html if request.format.htm?
  end

end
