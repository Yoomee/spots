module ApplicationControllerConcerns::HelperMethods

  module ClassMethods
    
    def plugin_installed?(plugin_name)
      File.exists?("#{RAILS_ROOT}/vendor/plugins/#{plugin_name}")      
    end

    def site_uses_fb_connect?
      plugin_installed?(:tramlines_facebook_connect) || included_modules.any? {|m| m.to_s == "Facebooker2::Rails::Controller"}
    end
    
  end

  def self.included(klass)
    klass.extend ClassMethods
    klass.helper_method :ie?
    klass.helper_method :ie6?
    klass.helper_method :ie7?    
    klass.helper_method :partial_exists?
    klass.helper_method :plugin_installed?    
    klass.helper_method :safari?
    klass.helper_method :site_uses_fb_connect?
    klass.helper_method :view_exists?
  end

  def ie?
    request.env['HTTP_USER_AGENT'].try(:downcase) =~ /msie/i
  end

  def ie6?
    request.env['HTTP_USER_AGENT'].try(:downcase) =~ /msie\s+6\.\d+/i
  end
  
  def ie7?
    request.env['HTTP_USER_AGENT'].try(:downcase) =~ /msie\s+7\.\d+/i
  end

  def partial_exists?(view_name)
    view_name = view_name.reverse.sub!(/_?\//, "_/").reverse
    ApplicationController.view_paths.any? do |path|
      File.exists?("#{path}/#{view_name}.html.haml")
    end
  end

  def plugin_installed?(plugin_name)
    self.class::plugin_installed?(plugin_name)
  end

  def safari?
    request.env['HTTP_USER_AGENT'].try(:downcase) =~ /safari/i
  end

  def site_uses_fb_connect?
    self.class::site_uses_fb_connect?
  end

  def view_exists?(view_name)
    ApplicationController.view_paths.any? do |path|
      File.exists?("#{path}/#{view_name}.html.haml")
    end
  end

end
