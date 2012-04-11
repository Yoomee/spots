require "erb"
class Tag < ActsAsTaggableOn::Tag
  
  validates_uniqueness_of :name
  
  include ERB::Util

  named_scope :with_id_in, lambda {|ids| {:conditions => ["tags.id IN (?)", ids]}}
  named_scope :without_id_in, lambda {|ids| {:conditions => ["tags.id NOT IN (?)", ids.blank? ? 0 : ids]}}
  named_scope :in_context, lambda {|context| {:joins => :taggings, :conditions => {:taggings => {:context => context}}}}
  named_scope :with_name_in, lambda {|names| {:conditions => ["name IN (?)", names]}}
  named_scope :with_members, :joins => :taggings, :conditions => {:taggings => {:taggable_type => "Member"}}, :group => "tags.id"

  named_scope :top_member_tags,
    :select => "tags.*, COUNT(DISTINCT taggings.taggable_id) AS tag_count",
    :joins => "INNER JOIN taggings ON (taggings.tag_id = tags.id)",
    :conditions => "taggings.taggable_type='Member'",
    :group => "tags.id",
    :order => 'tag_count DESC'

  named_scope :with_minimum_member_taggings, lambda{|n| {
    :select => "tags.*, COUNT(DISTINCT taggings.taggable_id) AS tag_count",
    :joins => "INNER JOIN taggings ON (taggings.tag_id = tags.id)",
    :conditions => ["taggings.taggable_type='Member' AND tag_count > ?", n],
    :group => "tags.id"
  }}

  class << self
    
    def create_tag_list(tag_list)
      find_or_create_all_with_like_by_name(ActsAsTaggableOn::TagList.from(tag_list))
    end
    
  end
  

  # TODO: Make urls look nicer e.g. Urban%2520planning -> Urban-planning
  def to_param
    url_encoded_name = name_was.blank? ? u(name) : u(name_was)
    url_encoded_name.gsub(".", "%2E")
  end
  
end
