module WallsHelper
  
  OLDER_POSTS_LINK_ID = "older_posts_link"
  
  def nothing_posted_message
    "There are no wall posts."
  end
  
  def older_posts_link(wall, options = {})
    options.reverse_merge!(:text => "Older posts")
    link_to_remote(options.delete(:text), {:url => older_posts_link_url(wall, options), :method => :get}, :id => "wall_#{wall.id}_older_wall_posts")
  end
  
  def older_posts_link_url(wall, url_options = {})
    url_options.reverse_merge!(:page => (params[:page].to_i + 1), :per_page => (params[:per_page] || 10), :reverse => params[:reverse])
    older_wall_wall_posts_path(wall, url_options)
  end
  
  def refresh_older_posts_link(wall, url_options = {})
    out = "$('#wall_#{wall.id}_older_wall_posts').attr('onclick', '').unbind('click');"
    out << "$('#wall_#{wall.id}_older_wall_posts').click(function() {#{remote_function(:url => older_posts_link_url(wall, url_options), :method => :get)}; return false;});"
  end
  
  def refresh_wall_form(wall_post, options = {})
    wall = wall_post.wall
    out = "$('#wall_#{wall.id}_wall_post_text_input .inline-errors').remove();"
    out << "$('#news_feed_item_wall_#{wall.id} li.error').removeClass('error');"
    if wall_post.errors.empty?
      if options[:rating_stars]
        out << "$('.wall_form').hide();"
      else
        out << "$('#wall_#{wall.id}_wall_post_text').attr('value', '');"
      end
    else
      out << "$('#wall_#{wall.id}_wall_post_text_input').append('#{escape_javascript(content_tag(:p, wall_post.errors[:text],:class => 'inline-errors'))}');"
    end
    out << "$(document).ready(function(){$('.labelify').labelify({ labelledClass: 'labelified' });});"
  end
  
  def render_comment_form(wall, options = {})
    options.reverse_merge!(:reverse => true)
    render_wall_form(wall, options)
  end
  
  def render_comments(wall, options = {})
    options.reverse_merge!(:reverse => true, :wall_title => "Comments")
    render_wall(wall, options)
  end
  
  def render_comments_body(wall, options = {})
    options.reverse_merge!(:reverse => true)
    render_wall_body(wall, options)
  end
  
  def render_ratings_wall(wall, options = {})
    options.reverse_merge!(:reverse => true, :wall_title => "Reviews", 
                           :rating_stars => true, :no_posts_message => "There are no reviews yet.",
                           :logged_out_message => "Log in to add your review.")
    render_wall(wall, options)
  end
  
  def render_wall(wall, options = {})
    wall = wall.wall if !wall.is_a?(Wall) && wall.respond_to?(:wall)
    options.reverse_merge!(:wall_title => "Wall", :reverse => false, :nothing_posted_message => nothing_posted_message, :logged_out_message => "Log in to post a comment", :rating_stars => false)
    render("walls/wall", {:wall => wall}.merge(options))
  end
  
  def render_wall_body(wall, options = {})
    options.reverse_merge!(:limit => nil, :no_posts_message => nothing_posted_message)
    render("walls/wall_body", {:wall => wall}.merge(options))
  end
  
  def render_wall_form(wall, options = {})
    return "" if options[:rating_stars] && wall.attachable_rated_by?(logged_in_member)
    options.reverse_merge!(:button_label => "Post", :reverse => false, :logged_out_message => "You must be logged in to post a comment")
    render("walls/form", {:wall => wall}.merge(options))
  end
  
  def render_wall_post_stars(rating_value)
    out = ""
    5.times {|i| out << content_tag(:span, '', :class => "wall_rating_star #{i < rating_value ? 'active' : ''}")}
    content_tag(:div, out, :class => "wall_post_rating_stars")
  end
  
end
