class Organisation < ActiveRecord::Base
  
  include TramlinesImages
  
  belongs_to :member
  has_many :time_slots
  has_many :time_slot_bookings, :through => :time_slots, :source => :bookings
  has_many :activities, :through => :time_slots, :uniq => true

  validates_presence_of :name, :member
  
  has_location
  
  def ordered_activities
    (activities.ascend_by_name + Activity.ascend_by_name).uniq
  end
  
end