module ApplicationControllerConcerns::Preprocess
  
  def self.included(klass)
    # Prevent XSS - taken from http://rorramblings.blogspot.com/2008/07/combating-xss.html
    # These files are in lib and vendor
    klass.send(:include, HtmlFilterHelper)
    klass.send(:attr_reader, :logged_in_member)
    # Just for compatibility with some plugins
    klass.send(:alias_method, :current_user, :logged_in_member)
    klass.send(:helper_method, :logged_in_member)
    klass.send(:helper_method, :logged_in_as?)    
    klass.send(:helper_method, :logged_in_member_id)
    klass.send(:helper_method, :logged_in_member_is_admin?)
    klass.send(:helper_method, :logged_in_member_path)
    # Standard before_filters
    klass.before_filter :get_logged_in_member, :sanitize_params, :clear_login_redirect_message, :gate_keep
  end
  
  def clear_login_redirect_message
    set_login_redirect_message('')
  end
  
  def find_logged_in_member
    if session[:logged_in_member_id]    
      Member.find_by_id(session[:logged_in_member_id]) || (session[:logged_in_member_id] = nil)
    end
  end
  
  # Check that the user has permission to carry out the requested action.
  def gate_keep
    options = params.merge({:controller => self.controller_path, :action => action_name})
    if !respond_to?(action_name)
      @page = "#{self.controller_path}/#{action_name}"
      @page_title = 'Whoops!'
      render_404
    elsif !allowed_to?(options, @logged_in_member)
      if @logged_in_member
        render_not_allowed_message
      elsif params[:login_hash_id] && params[:login_hash]
        report_error "Sorry, this page has expired."
      else
        redirect_to_login
      end
    end
  end
  
  def get_logged_in_member
    @logged_in_member = find_logged_in_member
    # For convenience
    @m = @logged_in_member
  end  
  
  def logged_in_as?(member)
    return false if member.nil?
    logged_in_member == member
  end
  
  def logged_in_member_id
    logged_in_member.try(:id)
  end
  
  def logged_in_member_is_admin?
    logged_in_member.try(:is_admin?)
  end
  
  def logged_in_member_path
    member_path(logged_in_member)
  end

  def login_member!(member, options = {})
    options.reverse_merge!(:redirect => true, :super => false)
    @logged_in_member = member
    session[:logged_in_member_id] = @logged_in_member.id
    unless options[:super] || request.remote_ip.blank? || request.remote_ip == @logged_in_member.ip_address
      @logged_in_member.update_attribute(:ip_address, request.remote_ip)
    end
    if Module.value_to_boolean(params[:in_popup])
      render(:text => "<script type='text/javascript'>window.close()</script>")
    elsif options[:redirect]
      options.reverse_merge!(:flash_notice => "Welcome back #{@logged_in_member.forename}! Thanks for logging in again.")
      flash[:notice] = options[:flash_notice] if options[:flash_notice].present?
      return redirect_to(params[:redirect_to]) if !params[:redirect_to].nil?
      if params[:iframe] || options[:iframe]
        responds_to_parent do
          render :update do |page|
            redirect_url = login_waypoint || waypoint || root_url
            if redirect_url.is_a?(Hash) && redirect_url.keys.collect(&:to_s).include?("anchor")
              redirect_url[:reload] = true
            end
            page.redirect_to(redirect_url)
          end
        end
      else
        redirect_to_waypoint_after_login
      end
    end
  end
  
  def logout_member!(options = {})
    options.reverse_merge!(:redirect_to => root_url)
    session[:logged_in_member_id] = nil
    case
      when options[:render]
        render(options[:render])
      when options[:call_method]
        send options[:call_method]
      else
        redirect_to(options[:redirect_to])
    end
  end    
  
  def redirect_to_login options = {}
    set_login_redirect_message(APP_CONFIG['insufficient_permission_message'] || '')
    set_waypoint
    return redirect_to(new_session_url)
  end
  
  def render_404
    render :template => 'application/404', :status => 404
  end

  # create a view to be used instead of the default error message
  # e.g. groups/show_permission_error.html.haml
  def render_not_allowed_message
    if view_exists?("#{controller_path}/#{action_name}_permission_error")
      render(:template => "#{controller_path}/#{action_name}_permission_error")
    else
      report_error "You are not allowed to view this page. If you believe this is wrong please contact us <a href='mailto:#{APP_CONFIG[:site_email]}'>here</a>."
    end
  end
    
  # Report a given error message
  def report_error(message)
    @message = message
    @page_title = 'Error'
    return render(:text => @message, :layout => true)
  end

  def set_login_redirect_message(message)
    session[:login_redirect_message] = message
  end
  
end
