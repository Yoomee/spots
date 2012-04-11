require 'rss'
require 'open-uri'
module ApplicationControllerConcerns::Twitter

  def self.included(klass)
    klass.helper_method :get_latest_tweet_from
    klass.helper_method :get_latest_tweets_from
  end

  # older methods still used in old client projects
  def get_latest_tweet_from(user, replies = false)
    get_latest_tweets_from(user, 1, replies).first
  end

  def get_latest_tweets_from(user, limit = 4, replies = false, with_dates = false, &block)
    if Rails.cache.to_s.match(/(ActiveSupport::Cache::MemCacheStore|MemCacheStoreWithDeleteMatched)/)
      tweets = Rails.cache.fetch("latest_tweets_from_#{user}#{replies ? '_with_replies' : '_without_replies'}#{with_dates ? '_with_dates' : '_without_dates'}", :expires_in => 1.hour) do
        fetch_latest_tweets_from(user, limit, replies, with_dates)
      end
    else
      tweets = fetch_latest_tweets_from(user, limit, replies, with_dates)
    end
    if block_given?
      tweets.each do |tweet|
        yield(tweet)
      end
    else
      tweets
    end
  end
  
  # newer version for getting tweets
  def latest_tweet_for(screen_name, options = {})
    latest_tweets_for(screen_name, options.merge(:limit => 1)).first
  end
  
  def latest_tweets_for(screen_name, options = {})
    options.reverse_merge!(:limit => 4, :list_id => nil)
    if Rails.cache.to_s.match(/(ActiveSupport::Cache::MemCacheStore|MemCacheStoreWithDeleteMatched)/)
      unique_name = "latest_#{options[:limit]}_tweets_for_#{screen_name}"
      unique_name << "_list_#{options[:list_id]}" if options[:list_id]
      tweets = Rails.cache.fetch(unique_name, :expires_in => 30.minutes) do
        Rails.logger.info "Getting #{unique_name} at #{Time.now}"
        fetch_latest_tweets_for(screen_name, options)
      end
    else
      tweets = fetch_latest_tweets_for(screen_name, options)
    end
    tweets.first(options[:limit].to_i)
  end
 
  private
  def fetch_latest_tweets_for(screen_name, options = {})
    options.reverse_merge!(:limit => 4, :list_id => nil)
    begin
      # to prevent going over Twitter rate limit
      if RAILS_ENV=='development'
        tweets_array = ActiveSupport::JSON.decode(TWITTER_JSON_FOR_DEVELOPMENT)      
      else
        if options[:list_id]
          tweets_json = open("http://api.twitter.com/1/#{screen_name}/lists/#{options[:list_id]}/statuses.json?per_page=#{options[:limit].to_i+1}&include_entities=false").read
        else
          tweets_json = open("http://api.twitter.com/1/statuses/user_timeline.json?count=#{options[:limit]}&include_entities=false&screen_name=#{screen_name}&include_rts=true").read
        end
        tweets_array = ActiveSupport::JSON.decode(tweets_json)
      end
      if tweets_array.is_a?(Array)
        return tweets_array.collect {|t| Struct::Tweet.new(t["text"], Time.parse(t["created_at"]), t["user"]["screen_name"], t["id"])}
      else
        Rails.logger.info("FAILED to fetch_latest_tweets_for #{screen_name}: Twitter error: #{tweets_array["error"]}")
      end
    rescue => e
      Rails.logger.info("FAILED to fetch_latest_tweets_for #{screen_name}: #{e}")
    rescue Timeout::Error => e
      Rails.logger.info("FAILED to fetch_latest_tweets_for #{screen_name}: #{e}")
    end
    []
  end
  
  # TODO: make sure dates are correct time zone
  def fetch_latest_tweets_from(user, limit, replies, with_dates)
    begin
      Rails.logger.info("Getting new tweets")
      rss = RSS::Parser.parse(open("http://twitter.com/statuses/user_timeline/#{user}.rss").read, false)
      items = replies ? rss.items : rss.items.reject {|item| item.title.match(/^.[^:]+:\s+@/)}
      if with_dates
        items.first(limit).collect {|i| Struct::Tweet.new(/^.[^:]+:\s+((\s|.)*)/.match(i.title)[1].gsub(%r{\n}, ' '), i.pubDate, i.id)}
      else
        items.first(limit).collect {|i| /^.[^:]+:\s+((\s|.)*)/.match(i.title)[1].gsub(%r{\n}, ' ')}
      end
    rescue => e
      Rails.logger.info("FAILED to fetch_latest_tweets_from #{user}: #{e}")
      ""
    rescue Timeout::Error => e
      Rails.logger.info("FAILED to fetch_latest_tweets_from #{user}: #{e}")      
      ""
    end
  end
  
end

Struct.new("Tweet", :text, :date, :screen_name, :id) unless Struct.const_defined?(:Tweet)

TWITTER_JSON_FOR_DEVELOPMENT = '[ 
    { 
      "text": "In pellentesque faucibus vestibulum. Nulla at nulla justo, eget luctus @ianmooney. Nulla facilisi. Duis aliquet egestas purus in blandit.",
      "created_at": "Thu Sep 22 10:01:09 +0000 2011", 
      "user": {
          "screen_name": "yoomeehq" 
      },
      "id": 1234567890
    }, 
    { 
      "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam in dui mauris. Vivamus hendrerit arcu sed erat #yoomee",
      "created_at": "Thu Sep 22 09:23:12 +0000 2011", 
      "user": { 
          "screen_name": "matkins" 
      },
      "id": 0987654321
    },
    { 
      "text": "Vivamus rutrum nunc non neque consectetur quis placerat neque lobortis. Nam nisl orci bibendum elit, eu euismod magna ut http://goo.gl/arnvB",
      "created_at": "Thu Sep 22 08:45:00 +0000 2011", 
      "user": { 
          "screen_name": "richwells" 
      },
      "id": 1357924680
    }, 
    { 
      "text": "RT @yoomeehq Nullam in dui mauris. Vivamus hendrerit arcu sed erat molestie vehicula. Sed auctor neque eu tellus.",
      "created_at": "Thu Sep 22 08:41:48 +0000 2011", 
      "user": { 
          "screen_name": "ianmooney" 
      },
      "id": 2468013579
    }, 
    { 
      "text": "Mauris iaculis porttitor posuere. Praesent id metus massa, ut blandit odio. Proin quis.",      
      "created_at": "Thu Sep 22 08:41:15 +0000 2011", 
      "user": { 
          "screen_name": "siwilkins" 
      },
      "id": 1692162349
    } 
]'

