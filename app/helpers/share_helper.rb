module ShareHelper
  
  def facebook_sharer_link(name, url)
    link_to(name, facebook_sharer_url(url), :class => "facebook_share_link",:onclick => "window.open(this.href, 'name', 'toolbar=0,status=0,menubar=0,height=400,width=600,top=' + ((screen.height/2)-200) + ',left=' + ((screen.width/2)-300));return false;")
  end
  
  def facebook_sharer_tags(options ={})
    options.reverse_merge!(:title => site_name, :description => site_slogan, :url => request.url)
    options[:image] = path_to_image("logo.jpg") if options[:image].blank?
    out = content_tag(:meta, nil, :property => "og:image", :content => site_url + options[:image])
    out << content_tag(:link, nil, :rel => "image_src", :href => site_url + options[:image])
    out << content_tag(:meta, nil, :property => "og:url", :content => options[:url])
    out << content_tag(:meta, nil, :property => "og:type", :content => "website")
    out << content_tag(:meta, nil, :property => "og:title", :content => options[:title])
    out << content_tag(:meta, nil, :property => "og:site_name", :content => site_name)
    out << content_tag(:meta, nil, :property => "og:description", :content => options[:description])
    out << content_tag(:meta, nil, :property => "fb:admins", :content => "61102010")
  end
  
  def facebook_sharer_url(url)
    "http://www.facebook.com/sharer.php?u=#{url}"
  end
  
  def fancy_share_link(model, link_text = "Share")
    link_to_box(link_text, "/share/#{model.class.to_s.underscore}/#{model.id}/options", :scrolling => false)
  end
  
  def google_plus_one(options = {})
    options.reverse_merge!(:count => false, :size => "medium")
    content_tag("g:plusone", nil, options)
  end
  
  def google_plus_one_js
    content_tag(:script, nil, :type => "text/javascript", :src =>"https://apis.google.com/js/plusone.js")
  end
  
  def render_share_link text="Share"
    link_to text, :controller => "share", :action => "new", :model_name => controller_name.to_s.singularize, :id => params[:id]
  end
  
  def tweet_button(options ={})
    options.reverse_merge!(:link_text => "Tweet", :count => false)
    link_options = {
      :class => "twitter-share-button",
      "data-count" => (options[:count] ? "" : "none")
    }
    link_options["data-text"] = options[:text] unless options[:text].blank?
    out = link_to(options[:link_text], "http://twitter.com/share?url=#{options[:url]}", link_options)
    out << content_tag(:script, nil, :src => "http://platform.twitter.com/widgets.js")
  end
  
  def twitter_share_button(name, url, text)
    out = javascript_include_tag("http://platform.twitter.com/widgets.js")
    out << link_to(name, "http://twitter.com/share?url=#{url}", :class => "twitter-share-button", "data-text" => text)
  end
  
  def twitter_share_link(name, url, text, related = nil)
    link_to(name, twitter_share_url(url, text, related), :class => "twitter_share_link", :onclick => "window.open(this.href, 'name', 'toolbar=0,status=0,menubar=0,height=400,width=600,top=' + ((screen.height/2)-200) + ',left=' + ((screen.width/2)-300));return false;")
  end
  
  def twitter_share_url(url, text, related = nil)
    "http://twitter.com/share?url=#{url}&text=#{text}&related=#{related}"
  end
  
end
