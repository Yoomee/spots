class TimeSlotBooking < ActiveRecord::Base
  
  belongs_to :member
  belongs_to :time_slot
  
  validates_presence_of :member, :time_slot, :starts_at
  
  validate :starts_at_is_in_the_future, :not_already_booked_for_this_day
  
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
  
end