module ApplicationControllerConcerns::HttpBasicAuthentication
  
  def self.included(klass)
    if http_basic_authenticated?
      klass.prepend_before_filter :http_basic_authenticate
    end
    klass.helper_method :http_basic_authenticated?
  end

  class << self
    
    def http_basic_authenticated?
      !%w(development test).include?(RAILS_ENV) && APP_CONFIG[:http_basic_username] && APP_CONFIG[:http_basic_password]  && APP_CONFIG[:http_basic_authenticate]
    end

  end
  
  def http_basic_authenticated?
    ApplicationControllerConcerns::HttpBasicAuthentication::http_basic_authenticated?
  end
  
  protected
  def http_basic_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == APP_CONFIG[:http_basic_username] && password == APP_CONFIG[:http_basic_password]
    end
  end
  
end