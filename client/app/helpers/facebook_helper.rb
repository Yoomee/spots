FacebookHelper.module_eval do
  
  def facebook_like_link
    content_tag(:div, '', :id => 'fb-root') +
    javascript_include_tag('http://connect.facebook.net/en_US/all.js#appId=173606316032061&amp;xfbml=1') + 
    "<fb:like href='#{request.url}' send='false' layout='button_count' width='200' show_faces='false' font=''></fb:like>"
  end    
  
end