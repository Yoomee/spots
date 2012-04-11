class OldPermalink < ActiveRecord::Base

  include PermalinkConcerns
  
  validates_presence_of :model
  
  default_scope :order => "created_at DESC"
  
end