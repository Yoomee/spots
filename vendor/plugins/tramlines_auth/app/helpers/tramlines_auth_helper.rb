# Set up
#
# Needs facebooker2 gem
#
# in client/config/initializers/facebooker2.rb:
# Facebooker2.load_facebooker_yaml
#
# client/app/controllers/application_controller.rb
# include Facebooker2::Rails::Controller
#
# in layouts/application.rb:
# in the head:
# =javascript_include_tag("http://connect.facebook.net/en_US/all.js")
# $(document).ready(function() {
#   FB.init({
#     appId  : '#{Facebooker2.app_id}',
#     status : true, // check login status
#     cookie : true, // enable cookies to allow the server to access the session
#     xfbml  : true  // parse XFBML
#   });
# });
# bottom of the body:
# %div{:id => "fb-root"}
  
module TramlinesAuthHelper
  
  def facebook_image_for(member, options = {})
    options[:width] ||= 100
    options[:linked] ||= false
    options[:facebook_logo] |= false
    if options[:size].blank?
      if options[:width].to_i <= 50
        if options[:height].blank? || options[:height] == options[:width]
          options[:size] = "square"
          options.delete(:height)
        else
          options[:size] = "thumb"
        end
        
      elsif options[:width].to_i <= 100
        options[:size] = "small"
      else
        options[:size] = "normal"
      end
    end
    # "<fb:profile-pic uid='#{member.fb_user_id}' linked='false' facebook-logo='false' size='#{options[:size]}' width='#{options[:width]}' height='#{options[:height]}'></fb:profile-pic>"
    options.reject! {|k,v| !k.to_s.in? %w{linked facebook_logo size width height}}
    fb_profile_pic(member.fb_user_id, options)
  end
  
  def refresh_fb_dom
    "FB.XFBML.parse();"
  end
  
  def redirect_to_fb_create(url_params={})
    js = update_page do |page|
      page.redirect_to(create_fb_session_path(url_params))
    end
    js.to_str
  end
  
  def show_denied_fb_perms_message
    js = update_page do |page|
      page["#fb_login_normal_header, #login_facebook_intro"].hide
      page["#fb_permission_header, #fb_permission_message"].show
      page.visual_effect(:highlight, "#fb_permission_message .fb_permission_title")
    end
    js.to_str
  end
  
end