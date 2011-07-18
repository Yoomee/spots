class TimeSlotBooking < ActiveRecord::Base
  
  belongs_to :member
  belongs_to :time_slot
  
  validates_presence_of :member, :time_slot, :starts_at
  
  validate :starts_at_is_in_the_future, :not_already_booked_for_this_day, :starts_at_is_within_time_limits, :starts_at_is_within_notice_period, :starts_at_is_on_an_allowed_day
  
  private
  def starts_at_is_in_the_future
    return true if !new_record? || starts_at.nil?
    errors.add(:starts_at, "must be in the future") unless starts_at > Time.now
  end
  
  def not_already_booked_for_this_day
    return true if time_slot.nil? || starts_at.nil?
    unless !time_slot.bookings.not_including(self).exists?(["DATE(time_slot_bookings.starts_at) = DATE(?)", starts_at])
      errors.add(:starts_at, "this spot is already booked")
    end
  end
  
  def starts_at_is_within_time_limits
    return true if !new_record? || starts_at.nil? || time_slot.nil?
    unless (starts_at <= Time.parse(time_slot.ends_at_string, starts_at) && starts_at >= Time.parse(time_slot.starts_at_string, starts_at))
      errors.add(:starts_at, "is outide the time limits")
    end
  end
  
  def starts_at_is_within_notice_period
    return true if !new_record? || starts_at.nil? || time_slot.nil?
    unless (starts_at >= time_slot.num_weeks_notice.weeks.ago && starts_at <= time_slot.num_weeks_notice.weeks.from_now)
      errors.add(:starts_at, "is outide the notice period")
    end 
  end
  
  def starts_at_is_on_an_allowed_day
    return true if starts_at.nil? || time_slot.nil?
    errors.add(:starts_at, "is on the wrong day") unless time_slot.send(starts_at.strftime("%a").downcase)
  end
  
end