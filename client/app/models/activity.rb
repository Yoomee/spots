class Activity < ActiveRecord::Base

  include TramlinesImages

  has_many :time_slots, :dependent => :destroy

  validates_presence_of :name

  named_scope :anytime, :conditions => {:activity_type => "anytime"}
  named_scope :volunteering, :conditions => {:activity_type => "volunteering"}

end
Activity::TYPES = %w{volunteering anytime}