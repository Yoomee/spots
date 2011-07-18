class Organisation < ActiveRecord::Base
  
  include TramlinesImages
  
  belongs_to :member
  has_many :time_slots
  has_many :activities, :through => :time_slots

  validates_presence_of :name, :member
  
  has_location
  
  def ordered_activities
    (activities.ascend_by_name + Activity.ascend_by_name).uniq
  end
  
end