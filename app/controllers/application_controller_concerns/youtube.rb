module ApplicationControllerConcerns::Youtube

  LINK_RE = /http\:\/\/www\.youtube\.com\/watch\?v=\w+/
  IMG_URL_RE = /http\:\/\/i\.[\w\.\/]+/
  
  def get_latest_youtube_video_from(channel)
    get_latest_youtube_videos_from(channel).first
  end
  
  def get_latest_youtube_videos_from(channel, limit = 5)
    if Rails.cache.to_s.in?(["ActiveSupport::Cache::MemCacheStore", "MemCacheStoreWithDeleteMatched"])
      videos = Rails.cache.fetch("latest_youtube_videos_from_#{channel}", :expires_in => 1.hour) do
        fetch_latest_youtube_videos_from(channel, limit)
      end
    else
      videos = fetch_latest_youtube_videos_from(channel, limit)
    end
    videos
  end
  
  private
  def fetch_latest_youtube_videos_from(channel, limit)
    rss = RSS::Parser.parse("http://gdata.youtube.com/feeds/base/users/#{channel}/uploads?alt=rss&amp;v=2&amp;orderby=published")
    items = rss.items
    items.first(limit).map {|i| Struct::YoutubeVideo.new(i.title, i.description.match(LINK_RE).to_s, i.description.match(IMG_URL_RE).to_s, i.pubDate)}
  end
  
end

Struct.new("YoutubeVideo", :name, :url, :image_url, :created_at)
