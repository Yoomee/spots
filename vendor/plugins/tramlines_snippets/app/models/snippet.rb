class Snippet < ActiveRecord::Base
  
  belongs_to :item, :polymorphic => true
  validates_uniqueness_of :name, :scope => [:item_id, :item_type], :unless => Proc.new{|snippet| snippet.item_id.nil? || snippet.item_type.blank?}

  named_scope :site_snippets, :conditions => "(name IS NOT NULL AND name != '') AND (item_id IS NULL OR item_id = '')"

  class << self
    
    def site_snippet(name)
      find_or_create_by_name_and_item_id(name.to_s, nil)
    end
    
  end

  def human_name
    return "" if name.blank?
    name.humanize.downcase
  end

  def text_is_blank?
    text.to_s.strip_tags.blank?
  end

  # before_save :set_item_delta_flag
  # 
  # private
  # def set_item_delta_flag
  #   if item.respond_to?(:delta)
  #     item.skip_save_snippets = true
  #     item.delta = true
  #     item.save
  #   end
  # end

end
