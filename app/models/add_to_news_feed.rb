module AddToNewsFeed
  
  def self.included(klass)
    klass.has_and_belongs_to_many :related_news_feed_items, :class_name => "NewsFeedItem", :uniq => true if klass.to_s == "Member"
    klass.has_many :news_feed_items, :as => :attachable, :dependent => :destroy
    klass.cattr_accessor :news_feed_actions, :on_news_feed_attributes, :except_news_feed_attributes, :news_feed_weighting, :group_news_feed_item_within
    klass.before_save :save_to_news_feed
  end

  attr_boolean_writer :skip_news_feed, :force_news_feed
  attr_reader :skip_news_feed, :force_news_feed
  attr_writer :news_feed_item_attributes

  # useful for creating a new news_feed_item if attachable is not a new_record?
  def create_news_feed_item!(attributes = {})
    self.force_news_feed = true
    self.news_feed_item_attributes = attributes
    save!
  end

  def group_news_feed_item?
    return false unless (item = news_feed_item_for_grouping)
    return false if item.updated_at.nil?
    (Time.now - item.updated_at) < group_news_feed_item_within
  end

  # overwrite in model
  def news_feed_item_for_grouping
    news_feed_items.first
  end

  def news_feed_item
    items = self.is_a?(Member) ? related_news_feed_items : news_feed_items
    news_feed_items.first
  end

  def news_feed_item_attributes
    @news_feed_item_attributes ||= {} 
  end

  private
  def save_to_news_feed
    return true if skip_news_feed
    group_news_feed_item? ? save_news_feed_item_for_grouping : save_new_news_feed_item
    true
  end
  
  def save_news_feed_item_for_grouping
    item = news_feed_item_for_grouping
    related_member = (self.is_a?(Member) ? self : nil)
    related_member = (respond_to?(:member) ? member : nil) if related_member.nil?
    unless related_member.nil?
      # removed and added so that related_member is the latest member
      item.members.delete(related_member)
      item.members << related_member
    end
    item.update_attributes(:updated_at => Time.now)    
  end
  
  def save_new_news_feed_item
    if new_record?
      if news_feed_actions.include?('create') && news_feed_items.empty?
        news_feed_item_attributes[:updated] = false
      else
        return true unless force_news_feed
      end
    elsif news_feed_actions.include?('update')
      attribute_changes = on_news_feed_attributes.empty? ? changes.keys - except_news_feed_attributes : changes.keys & on_news_feed_attributes
      if !attribute_changes.blank?
        news_feed_item_attributes.merge!(:updated => true, :attribute_changes => attribute_changes.join(', '))
      else
        return true unless force_news_feed
      end
    else
      return true unless force_news_feed
    end
    if self.class.to_s == "Member"
      news_feed_item_attributes[:members] = [self]
    else
      news_feed_item_attributes[:members] = [member] if respond_to?(:member) && !member.nil?
    end
    news_feed_items.build(news_feed_item_attributes.merge!(:weighting => news_feed_weighting))
  end

end