class TweetsController < ApplicationController
  
  def index
    tweets = latest_tweets_for(params[:screen_name], :limit => params[:limit], :list_id => params[:list_id])
    render :partial => "tweets/list", :locals => {:tweets => tweets, :screen_name => params[:screen_name], :show_screen_name => !params[:list_id].blank?, :show_dates => Module::value_to_boolean(params[:show_dates])}
  end
  
end
  