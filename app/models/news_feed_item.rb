class NewsFeedItem < ActiveRecord::Base
  
  default_scope :order => "updated_at DESC"
  
  belongs_to :attachable, :polymorphic => true
  has_and_belongs_to_many :members, :uniq => true

  named_scope :for_member, lambda {|member| {:joins => :members, :conditions => {:members => {:id => member.id}}, :group => "news_feed_items.id"}}
  named_scope :no_duplicates, :group => "news_feed_items.attachable_type, news_feed_items.attachable_id, IF(news_feed_items.updated=0, news_feed_items.updated, news_feed_items.id)" 

  def attachable_is_a?(klass)
    attachable.is_a?(klass)
  end
  
  def attachable_name
    if attachable.respond_to?(:name)
      attachable.name
    elsif attachable.respond_to?(:title)
      attachable.title
    end
  end
  
  def delete_for!(member)
    return false if member.nil?
    if members.delete(member)
      members.empty? ? self.destroy : self
    else
      false
    end
  end
  
  def member
    members.first || (attachable.respond_to?(:member) ? attachable.member : nil)
  end
  
  def old_partial_name
    "#{attachable_type.underscore}_news_feed_item"
  end
  
  def partial_name
    attachable_type.underscore
  end
  
end