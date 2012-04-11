module NewsFeedHelper

  def existing_news_feed_partial(news_feed_item)
    if view_exists?("news_feed/_#{news_feed_item.partial_name}")
      news_feed_item.partial_name
    elsif view_exists?("news_feed/_#{news_feed_item.old_partial_name}")
      news_feed_item.old_partial_name
    else
      nil
    end
  end
  
  def news_feed_option_links(news_feed_item, options = {})
    link_if_allowed("Delete", news_feed_item, {:method => :delete, :confirm => "Are you sure?", :class => 'delete'})
  end

  def get_news_feed_items(attachable_or_named_scope)
    if attachable_or_named_scope.nil?
      NewsFeedItem.no_duplicates
    elsif attachable_or_named_scope.class.to_s.in?(%w{String Symbol})
      # check named_scope exists, preventing passing in :destroy_all etc.
      attachable_or_named_scope = "latest" if !NewsFeedItem.scopes.keys.include?(attachable_or_named_scope.to_sym)
      NewsFeedItem.no_duplicates.send(attachable_or_named_scope)
    else
      attachable_or_named_scope.is_a?(Member) ? attachable_or_named_scope.related_news_feed_items : attachable_or_named_scope.news_feed_items
    end
  end

  def render_news_feed(*args)
    options = args.extract_options!.reverse_merge(:per_page => 10, :ajax_loader => "ajax_loader.gif", :older_link_name => "Older items", :container_id => "news_feed")
    attachable_or_named_scope = args.first
    if !options[:items].nil?
      news_feed_items = options[:items]
    else
      news_feed_items = get_news_feed_items(attachable_or_named_scope)
    end
    news_feed_items = news_feed_items.paginate(:page => 1, :per_page => options[:per_page])
    render('news_feed/news_feed', options.merge(:news_feed_items => news_feed_items, :attachable => attachable_or_named_scope))
  end
  
  def render_news_feed_item(news_feed_item, options = {})
    options[:class] = options[:class].to_s << " news_feed_item #{news_feed_item.attachable_type.underscore}_news_feed_item"
    locals = {:news_feed_item => news_feed_item, :news_feed_attachable => options.delete(:news_feed_attachable)}
    content_tag(:div, options.merge(:id => "news_feed_item_#{news_feed_item.id}")) do
      if partial_name = existing_news_feed_partial(news_feed_item)
        render("news_feed/#{partial_name}", locals.merge(news_feed_item.attachable_type.underscore.to_sym => news_feed_item.attachable))
      else
        render('news_feed/news_feed_item', locals)
      end
    end
  end
  
  def attachable_description(news_feed_item)
    if news_feed_item.updated?
      out = "the #{news_feed_item.attachable_type.underscore.humanize}"
    else
      out = "a new #{news_feed_item.attachable_type.underscore.humanize}"
    end
    news_feed_item.attachable_name ? out + " called #{link_to(news_feed_item.attachable_name, news_feed_item.attachable)}" : out
  end
  
  def news_feed_commented_on_text(comment, options = {})
    first_member = options[:member_being_viewed] || comment.news_feed_item.members.dup.last
    if first_member.nil?
      out = "Someone "
    else
      out = link_to(first_member, first_member)
      other_members = comment.news_feed_item.members.not_including(first_member)
      other_members.first(2).each do |member|
        out += (other_members.last == member) ? " and " : ", "
        out += link_to(member.to_s, member)
      end
      out += " and #{pluralize(other_members.size - 2, "other")} " if other_members.size > 2
    end
    out << " replied to "
    if (comment.attachable && comment.attachable.respond_to?(:member) && comment.attachable.member)
      if other_members.empty? && comment.attachable.owned_by?(first_member)
        description = "their "
      else
        if comment.attachable.is_a?(Status) || (comment.attachable.is_media? && comment.attachable.untitled?)
          description = "#{comment.attachable.member}'s "
        else
          description = "#{link_to(comment.attachable.member, comment.attachable.member)}'s "
        end
      end
    else
      description = "the "
    end
    description << (comment.attachable_type=="Page" ? "article" : "#{comment.attachable_type.underscore.humanize.downcase}")
    if comment.attachable.is_media? && comment.attachable.untitled?
      out << link_to(description, comment.attachable)
    elsif comment.attachable.is_a?(Status)
      out << link_to(description, comment.attachable.member)
    else
      out << "#{description} - "
      out << link_to(comment.attachable, comment.attachable)
    end
  end
  
  def older_news_feed_javascript
    content_for :head do
      javascript_tag do
        "var NewsFeed = {
          loading: function() {
            $('#news_feed_older_items_link').hide(0, function() {
              $('#news_feed_older_items_loader').show();
            });
          },
          complete: function() {
            $('#news_feed_older_items_loader').hide(0, function() {
              $('#news_feed_older_items_link').show();
            });
          }
        };"
      end
    end
  end
  
  def older_news_feed_link_html(options = {})
    options.reverse_merge!(:name => "Older items", :page => 2, :per_page => 10)
    attachable = options.delete(:attachable)
    url_options = options.delete(:url_options) || {}
    url_options.reverse_merge!(:id => attachable, :type => attachable.class.to_s, :name => options[:name],
                               :page => options.delete(:page), :per_page => options.delete(:per_page))
    link_to_remote(options[:name], 
                  {:url => older_news_feed_items_path(url_options),
                   :loading => "NewsFeed.loading()",
                   :complete => "NewsFeed.complete()"}.merge(:html => options.merge(:id => "news_feed_older_items_link")))
  end
  
  def older_news_feed_link(options = {})
    older_news_feed_javascript    
    options.reverse_merge!(:ajax_loader => "ajax_loader.gif")
    loader_html = content_tag(:div, image_tag(options.delete(:ajax_loader)), :id => "news_feed_older_items_loader", :style => "display:none")
    older_news_feed_link_html(options) + loader_html
  end
  
end