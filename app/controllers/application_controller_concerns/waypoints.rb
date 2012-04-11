module ApplicationControllerConcerns::Waypoints

  def self.included(klass)
    klass.cattr_accessor :skipped_waypoints
    klass.skipped_waypoints = []
    klass.after_filter :set_waypoint, :only => %w{index list show}
    klass.helper_method :waypoint, :login_waypoint
    klass.extend Classmethods    
  end
  
  module Classmethods

    def dont_set_waypoint_for(*actions)
      self.skipped_waypoints = actions.flatten.collect(&:to_s)
    end

    def skip_waypoint?(action)
      self.skipped_waypoints.include?(action.to_s)
    end
    
  end
  
  def clear_login_waypoint!
    session[:login_waypoint] = nil
  end
  
  def clear_waypoint!
    session[:waypoint] = nil
  end
  
  def login_waypoint
    session[:login_waypoint]
  end
  
  def skip_waypoint?(action = action_name)
    self.class::skip_waypoint?(action)
  end
  
  def redirect_to_waypoint
    redirect_to waypoint || home_url
  end
  
  def redirect_to_waypoint_after_login
    login_waypoint ? redirect_to(login_waypoint) : redirect_to_waypoint
  end
  
  def redirect_to_waypoint_after_destroy
    if waypoint.nil? || (waypoint[:controller].match(/\/?#{controller_path}/) && waypoint[:action] == "show")
      redirect_to :action => "index"
    else
      redirect_to waypoint
    end
  end
  
  def set_waypoint
    unless skip_waypoint? || request.xhr?
      session[:waypoint] = params.dup
      session[:waypoint][:controller] = "/#{controller_path}"
      session[:waypoint][:action] = action_name
      logger.info "SET waypoint to #{session[:waypoint]}"
    end
  end
  
  def waypoint
    session[:waypoint]
  end
  
end