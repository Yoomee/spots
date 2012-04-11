module SessionsHelper
  
  # used in new session form, adds hidden_fields to be used to redirect user after session#create
  def after_login_redirect_to(url_options)
    url_options = ActionController::Routing::Routes.recognize_path(url_options, :method => :get) if !url_options.is_a?(Hash)
    out = ""
    url_options.each_pair do |index, value|
      out << hidden_field(:redirect_to, index, :value => value)
    end
    out
  end
  
  def render_login_redirect_message
    content_tag(:div, session[:login_redirect_message], :id => 'login_redirect_message') if session[:login_redirect_message]
  end
  
end