class Organisation < ActiveRecord::Base
  
  include TramlinesImages
  
  belongs_to :member
  has_many :time_slots, :dependent => :destroy
  has_many :time_slot_bookings, :through => :time_slots, :source => :bookings
  has_many :activities, :through => :time_slots, :uniq => true

  after_create :send_emails

  delegate :email, :to => :member

  has_location

  validates_presence_of :name, :member, :location, :group_type
  
  accepts_nested_attributes_for :member
  
  named_scope :with_activity, lambda {|activity| {:joins => :activities, :conditions => {:activities => {:id => activity.id}}}}
  named_scope :visible, {:conditions => {:awake => true, :confirmed => true}}

  def active?
    confirmed? && awake?
  end
  
  def asleep?
    !awake?
  end
  
  def ordered_activities
    (activities.volunteering.ascend_by_name + Activity.volunteering.ascend_by_name).uniq
  end
  
  def status
    case
    when active?
      'active'
    when !confirmed?
      'unconfirmed'
    when asleep?
      'asleep'
    end
  end
  
  def validate
    if member && member.phone.blank?
      member.errors.add(:phone, "can't be blank")
    end
  end
  
  def volunteers_changed_in_past_day?
    time_slot_bookings.any? {|booking| booking.updated_at > 1.day.ago}
  end
  
  private
  def send_emails
    Notifier.deliver_organisation_signup_for_admin(self) if Member.anna
    Notifier.deliver_organisation_signup_for_organisation(self)
  end
  
end
Organisation::GROUP_TYPES = ["Children up to 12", "Young people 12-19", "Older people 65+", "Carers people with learning disabilities", "People with health conditions"]
Organisation::SIZE_OPTIONS = ["0-30", "30-50", "50-100", "100+"]