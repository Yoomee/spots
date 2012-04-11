module TwitterHelper
  
  def highlight_twitter_all tweet
    highlight_tweet_links(highlight_twitter_users(highlight_twitter_hash_tags(tweet)))
  end
  
  # TODO: auto_link call may need to change for new version of Rails
  # auto_link(tweet, :href_options => {:target => "_blank"})
  def highlight_tweet_links tweet
    return '' if tweet.nil?
    tweet = auto_link(tweet, :all, :target => "_blank")
    highlight_twitter_users(highlight_twitter_hash_tags(tweet))
  end
  
  def highlight_twitter_users(tweet)
    tweet.gsub(/@([\w|\d]+)/, '<a target="_blank" href="http://www.twitter.com/\1">@\1</a>')
  end
  
  def highlight_twitter_hash_tags(tweet)
    tweet.gsub(/#([\w|\d]+)/, '<a target="_blank" href="http://twitter.com/search?q=%23\1">#\1</a>')
  end
  
  def render_latest_tweets_for(screen_name, options = {})
    options.reverse_merge!(:limit => 4, :ajax_loader => "ajax_loader.gif", :show_dates => false, :list_id => nil)
    container_name = "tweet_list_#{screen_name}"
    container_name << "_list_#{options[:list_id]}" if options[:list_id]
    content_for :head do
      javascript_tag do
        "$(document).ready(function() {
          $('##{container_name}').load('#{escape_javascript(tweets_path(:screen_name => screen_name, :limit => options[:limit], :list_id => options[:list_id], :show_dates => options[:show_dates]))}');  
        });"
      end
    end
    content_tag(:div, image_tag(options[:ajax_loader]), :id => container_name, :class => "tweet_list")
  end
  
end