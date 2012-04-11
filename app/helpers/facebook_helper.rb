module FacebookHelper
  
  def facebook_like_box(link, options = {})
    options.reverse_merge!(:width => 296, :height => 282, :header => true, :stream => false, :connections => 5, :colorscheme => "light")
    options_string = ""
    options.each_pair{|k,v| options_string << "&amp;#{k}=#{v}"}
    link = "http#{options[:ssl] ? 's': ''}://www.facebook.com/plugins/likebox.php?href=#{CGI.escape(link)}#{options_string}"
    content_tag :iframe, "", :src => link, :scrolling =>"no", :frameborder=>"0", :style=>"border:none; width:#{options[:width]}px; height:#{options[:height]}px;", :allowTransparency => "true"
  end

  # def facebook_like_link(options = {})
  #   return "" if APP_CONFIG['facebook_app_id'].blank? || ie6?
  #   options.reverse_merge!(:layout => "button_count", :url => request.url)
  #   content_tag(:div, '', :id => 'fb-root') +
  #   javascript_include_tag("http://connect.facebook.net/en_US/all.js#appId=#{APP_CONFIG['facebook_app_id']}&amp;xfbml=1") + 
  #   "<fb:like href='#{options[:url]}' send='false' width='450' show_faces='false' layout='#{options[:layout]}' font=''></fb:like>"
  # end

  def facebook_like_link(options = {})
    return "" if ie6?
    options.reverse_merge!(:layout => "button_count", :url => request.url)
    src_url = "//www.facebook.com/plugins/like.php?href=#{options[:url]}&amp;send=false&amp;layout=#{options[:layout]}&amp;width=50&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;font=segoe+ui&amp;height=21"
    content_tag(:iframe, '',:src => src_url, :scrolling => "no", :frameborder => "0",  :style => "border:none; overflow:hidden; width:50px; height:21px;", :allowTransparency => "true")
  end

end