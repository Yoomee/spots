class TimeSlotBooking < ActiveRecord::Base
  
  belongs_to :member
  belongs_to :time_slot

  before_validation :set_starts_at
  
  validates_presence_of :member, :time_slot, :starts_at
  validate :starts_at_is_in_the_future, :not_already_booked_for_this_day, :starts_at_is_within_time_limits, :starts_at_is_within_notice_period, :starts_at_is_on_an_allowed_day
  
  after_create :send_emails_for_create
  
  attr_writer :starts_at_time_string
  attr_accessor :email_message
  attr_boolean_accessor :cancel
  
  formatted_date_accessor :starts_at
  
  delegate :activity, :activity_name, :organisation, :note, :to => :time_slot, :allow_nil => true
  delegate :email, :location, :member, :name, :to => :organisation, :prefix => true
  delegate :email, :to => :member, :prefix => true
  
  def in_future?
    starts_at > Time.now
  end
  
  def starts_at_time_string
    return nil if starts_at.nil? && time_slot.nil?
    @starts_at_time_string || (starts_at || time_slot.starts_at).strftime("%H:%M")
  end
  
  def starts_at_neat_string
    starts_at.strftime("%d %b at %H:%M")
  end
  
  private
  def set_starts_at
    return true if starts_at.nil? || starts_at_time_string.blank?
    self.starts_at = Time.zone.parse(starts_at_time_string, starts_at)
  end
  
  def starts_at_is_in_the_future
    return true if !new_record? || starts_at.nil?
    errors.add(:starts_at, "must be in the future") unless starts_at > Time.zone.now
  end
  
  def not_already_booked_for_this_day
    return true if time_slot.nil? || starts_at.nil?
    unless !time_slot.bookings.not_including(self).exists?(["DATE(time_slot_bookings.starts_at) = DATE(?)", starts_at])
      errors.add(:starts_at, "this spot is already booked")
    end
  end
  
  def starts_at_is_within_time_limits
    return true if !new_record? || starts_at.nil? || time_slot.nil?
    unless (starts_at <= Time.zone.parse((time_slot.ends_at - time_slot.duration.minutes).try(:strftime, "%H:%M"), starts_at) && starts_at >= Time.zone.parse(time_slot.starts_at_string, starts_at))
      errors.add(:starts_at, "is outide the time limits")
    end
  end
  
  def starts_at_is_within_notice_period
    return true if !new_record? || starts_at.nil? || time_slot.nil?
    unless (starts_at.to_date >= time_slot.num_weeks_notice.weeks.from_now.to_date)
      errors.add(:starts_at, "you need to give at least #{time_slot.num_weeks_notice} weeks notice")
    end 
  end
  
  def starts_at_is_on_an_allowed_day
    return true if starts_at.nil? || time_slot.nil?
    errors.add(:starts_at, "is on the wrong day") unless time_slot.send(starts_at.strftime("%a").downcase)
  end
  
  private
  def send_emails_for_create
    Notifier.deliver_time_slot_booking_for_volunteer(self)
    Notifier.deliver_time_slot_booking_for_organisation(self)
  end
  
end