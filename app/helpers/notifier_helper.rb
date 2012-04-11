module NotifierHelper
  
  def important_email_content(&block)
    content_tag(:div, :style => "font-size: 16px;color: #333;", &block)
  end
  
end