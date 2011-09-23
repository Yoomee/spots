class Activity < ActiveRecord::Base

  include TramlinesImages

  has_many :documents, :dependent => :destroy
  has_many :organisations, :through => :time_slots
  has_many :time_slots, :dependent => :destroy
  
  validates_presence_of :name

  default_scope :order => "weight, created_at DESC"
  
  search_attributes %w{name description}

  named_scope :anytime, :conditions => {:activity_type => "anytime"}
  named_scope :confirmed, :joins => :organisation, :conditions => {:organisation => {:confirmed => true}}
  named_scope :volunteering, :conditions => {:activity_type => "volunteering"}

  def anytime?
    activity_type == 'anytime'
  end

end
Activity::TYPES = %w{volunteering anytime}