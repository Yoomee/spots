require 'rubygems'
require 'open-uri'
class LinksWorker < Workling::Base

  # include Simplificator::Webthumb
  # 
  # def get_meta_data(url)
  #   require 'hpricot'
  #   page = Hpricot open(url)
  #   title_element = page.at('title')
  #   title = title_element.nil? ? url : title_element.inner_html.to_s.strip
  #   description_element = page.at("meta[@name='description']")
  #   description = description_element.nil? ? "" : description_element['content']
  #   [title, description]
  # end
  # 
  # def get_webthumb(url)
  #   wt = Webthumb.new(APP_CONFIG['webthumb_key'])
  #   job = wt.thumbnail(:url => url)
  #   job.fetch_when_complete(:large)
  # end
  # 
  # def save_site_info(options)
  #   unless RAILS_ENV.to_sym == :test
  #     link = Link.find(options[:link_id])
  #     begin
  #       link.image = get_webthumb(link.url)
  #       link.title, link.description = get_meta_data(link.url)
  #       link.url_error = false
  #     rescue
  #       link.url_error = true
  #     end
  #     link.save
  #   end
  # end
  
end