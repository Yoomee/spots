class Organisation < ActiveRecord::Base
  
  include TramlinesImages
  
  belongs_to :member
  has_many :time_slots, :dependent => :destroy
  has_many :time_slot_bookings, :through => :time_slots, :source => :bookings
  has_many :activities, :through => :time_slots, :uniq => true

  delegate :email, :to => :member

  has_location

  validates_presence_of :name, :member, :location, :group_type
  
  accepts_nested_attributes_for :member
  
  named_scope :with_activity, lambda {|activity| {:joins => :activities, :conditions => {:activities => {:id => activity.id}}}}
  
  def ordered_activities
    (activities.volunteering.ascend_by_name + Activity.volunteering.ascend_by_name).uniq
  end
  
  def validate
    if member && member.phone.blank?
      member.errors.add(:phone, "can't be blank")
    end
  end
  
end
Organisation::GROUP_TYPES = ["Children up to 12", "Young people 12-19", "Older people 65+", "Carers people with learning disabilities", "People with health conditions"]
Organisation::SIZE_OPTIONS = ["0-30", "30-50", "50-100", "100+"]