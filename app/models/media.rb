# make open-uri always write Tempfile, never StringIO, so that video thumbnails can be saved
require 'open-uri'
OpenURI::Buffer.module_eval do
  remove_const :StringMax
  const_set :StringMax, 0
end

module Media
  
  def self.included(klass)
    klass.add_to_news_feed(:only => "create")
    klass.belongs_to :attachable, :polymorphic => true
    klass.belongs_to :member
    klass.validates_presence_of :member
    alias_method :to_s, :name
  end
  
  def untitled?
    read_attribute(:name).blank?
  end
  
  def name
    untitled? ? "Untitled #{self.class.to_s}" : read_attribute(:name)
  end
  
  def type_name
    self.class.to_s.humanize.downcase
  end
  
end