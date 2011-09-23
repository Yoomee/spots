class TimeSlot < ActiveRecord::Base
  
  belongs_to :activity
  belongs_to :organisation
  has_many :bookings, :class_name => "TimeSlotBooking", :dependent => :destroy
  
  validates_presence_of :activity, :organisation, :starts_at, :ends_at
  validates_order_of :starts_at, :ends_at
  validate :presence_of_days

  delegate :description, :name, :email, :to => :organisation, :prefix => true
  delegate :has_lat_lng?, :lat_lng, :lat, :lng, :num_weeks_notice, :to => :organisation
  delegate :name, :to => :activity, :prefix => true

  named_scope :confirmed, :joins => :organisation, :conditions => {:organisations => {:confirmed => true}}
  named_scope :group_by_organisation, :group => "time_slots.organisation_id"

  def day_integers
    out = []
    TimeSlot::DAYS.each_with_index do |day, index|
      if day == :sun
        out << 0 if sun?
      else
        out << index+1 if send(day)
      end
    end
    out
  end
  
  # Length of each slot in minutes
  def duration
    30
  end
  
  def ends_at_string
    @ends_at_string || ends_at.try(:strftime, "%H:%M") || "17:00"
  end
  
  def ends_at_string=(value)
    @ends_at_string = value
    self.ends_at = Time.zone.parse("2000-01-01 #{value}")
  end
  
  def existing_bookings_json
    bookings.starts_at_greater_than(num_weeks_notice.weeks.from_now).collect {|b| b.starts_at.strftime("%a %b %d %Y")}.to_json
  end
  
  def last_time
    duration > 60 ? (ends_at - (duration * 60)) : (ends_at - 3600)
  end

  def possible_time_strings
    (starts_at..last_time).step(duration.minutes).collect {|t| t.strftime("%H:%M")}
  end
  
  def starts_at_string
    @starts_at_string || starts_at.try(:strftime, "%H:%M") || "09:00"
  end
  
  def starts_at_string=(value)
    @starts_at_string = value
    self.starts_at = Time.zone.parse("2000-01-01 #{value}")
  end
  
  def timespan(am_pm = true)
    if am_pm
      "#{starts_at.strftime("%H:%M%p")} - #{ends_at.strftime("%H:%M%p")}".downcase
    else
      "#{starts_at_string} - #{ends_at_string}"
    end
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
