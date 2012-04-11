module SettingsHelper

  def site_email
    APP_CONFIG['site_email']
  end
  
  def site_name
    APP_CONFIG['site_name']
  end
  
  def site_slogan
    APP_CONFIG['site_slogan']
  end
  
  def site_url
    url = APP_CONFIG['site_url'].dup
    url = url.match(/^http/) ? url : "http://#{url}"
    url.chomp("/")
  end
  
  def site_url_without_protocol
    url = site_url.dup
    url.gsub(/^\w+:\/\//, '')
  end

  def site_host
    APP_CONFIG['site_url'].match(/^https?:\/\/([\w\.]+)/)[1]
  end
  
end
