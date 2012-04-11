class NewsFeedItemsController < ApplicationController
  
  admin_only :destroy
  
  def destroy
    @news_feed_item = NewsFeedItem.find params[:id]
    if @news_feed_item.delete_for!(@logged_in_member)
      flash[:notice] = 'News Feed Item deleted'
    else
      flash[:error] = 'News Feed Item could not be deleted'
    end
    redirect_to_waypoint
  end
  
  def older
    # attachable could be a record (e.g. a member) or a named scope (e.g. 'for_game')
    if params[:id]
      attachable_or_named_scope = params[:type].in?(%w{String Symbol}) ? params[:id] : params[:type].constantize.find(params[:id])
    end
    render :update do |page|
      news_feed_items = get_news_feed_items(attachable_or_named_scope)
      news_feed_items = news_feed_items.paginate(:page => params[:page], :per_page => params[:per_page])
      news_feed_items.each do |news_feed_item|
        page.insert_html :bottom, :news_feed, render_news_feed_item(news_feed_item)
      end
      if WillPaginate::ViewHelpers.total_pages_for_collection(news_feed_items) > params[:page].to_i
        page[:news_feed_older_items_link].replace(older_news_feed_link_html(:attachable => attachable_or_named_scope, :page => (params[:page].to_i + 1), :per_page => params[:per_page], :name => params[:name]))
      else
        page[:news_feed_older_items_link].replace("")
      end
    end    
  end
  
end