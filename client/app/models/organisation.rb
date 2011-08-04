class Organisation < ActiveRecord::Base
  
  include TramlinesImages
  
  belongs_to :member
  has_many :time_slots, :dependent => :destroy
  has_many :time_slot_bookings, :through => :time_slots, :source => :bookings
  has_many :activities, :through => :time_slots, :uniq => true

  attr_accessor :group, :group_specific_needs

  has_location

  validates_presence_of :name, :member, :location
  
  accepts_nested_attributes_for :member
  
  named_scope :with_activity, lambda {|activity| {:joins => :activities, :conditions => {:activities => {:id => activity.id}}}}
  
  def ordered_activities
    (activities.volunteering.ascend_by_name + Activity.volunteering.ascend_by_name).uniq
  end
  
end