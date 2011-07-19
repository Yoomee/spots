class TimeSlot < ActiveRecord::Base
  
  belongs_to :activity
  belongs_to :organisation
  has_many :bookings, :class_name => "TimeSlotBooking"
  
  validates_presence_of :activity, :organisation, :starts_at, :ends_at
  validates_order_of :starts_at, :ends_at
  validate :presence_of_days

  delegate :name, :to => :activity, :prefix => true
  delegate :description, :name, :to => :organisation, :prefix => true
  delegate :has_lat_lng?, :lat_lng, :to => :organisation

  named_scope :group_by_organisation, :group => "time_slots.organisation_id"
  
  def ends_at_string
    @ends_at_string || "%02d:00" % (ends_at.try(:hour) || 17)
  end
  
  def ends_at_string=(value)
    @ends_at_string = value
    self.ends_at = Time.parse("2000-01-01 #{value}")
  end
  
  def starts_at_string
    @starts_at_string || "%02d:00" % (starts_at.try(:hour) || 9)
  end
  
  def starts_at_string=(value)
    @starts_at_string = value
    self.starts_at = Time.parse("2000-01-01 #{value}")
  end
  
  def timespan(am_pm = true)
    if am_pm
      "#{starts_at.strftime("%H:00%p")} - #{ends_at.strftime("%H:00%p")}".downcase
    else
      "#{starts_at_string} - #{ends_at_string}"
    end
  end
  
  # TODO: make this content managed
  def num_weeks_notice
    2
  end
  
  def possible_time_strings
    (starts_at.hour..ends_at.hour).collect {|h| "%02d:00" % h}
  end
  
  def to_s
    "#{activity_name} with #{organisation_name}"
  end
  
  private
  def presence_of_days
    errors.add_to_base("Please select at least one day of the week") if TimeSlot::DAYS.all? {|d| !send(d)}
  end
  
end

TimeSlot::DAYS = [:mon, :tue, :wed, :thu, :fri, :sat, :sun]