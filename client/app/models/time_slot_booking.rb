# Copyright 2011 Yoomee Digital Ltd.
# 
# This software and associated documentation files (the
# "Software") was created by Yoomee Digital Ltd. or its agents
# and remains the copyright of Yoomee Digital Ltd or its agents
# respectively and may not be commercially reproduced or resold
# unless by prior agreement with Yoomee Digital Ltd.
# 
# Yoomee Digital Ltd grants Spots of Time (the "Client") 
# the right to use this Software subject to the
# terms or limitations for its use as set out in any proposal
# quotation relating to the Work and agreed by the Client.
# 
# Yoomee Digital Ltd is not responsible for any copyright
# infringements caused by or relating to materials provided by
# the Client or its agents. Yoomee Digital Ltd reserves the
# right to refuse acceptance of any material over which
# copyright may apply unless adequate proof is provided to us of
# the right to use such material.
# 
# The Client shall not be permitted to sub-license or rent or
# loan or create derivative works based on the whole or any part
# of the Works supplied by us under this agreement without prior
# written agreement with Yoomee Digital Ltd.
require 'forwardable'
class TimeSlotBooking < ActiveRecord::Base

  extend Forwardable
  
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
  def_delegator :member, :full_name, :member_name
  def_delegator :member, :forename, :member_forename

  named_scope :for_activity, lambda{|activity| {:joins => "INNER JOIN time_slots AS bts ON time_slot_bookings.time_slot_id=bts.id", :conditions => ["bts.activity_id=?", activity.id]}}
  named_scope :in_past_day, lambda {{:conditions => ["time_slot_bookings.starts_at < ? AND time_slot_bookings.starts_at >= ?", Time.zone.now, 24.hours.ago]}}
  named_scope :with_activity, :joins => "INNER JOIN time_slots ON time_slots.id=time_slot_bookings.time_slot_id INNER JOIN activities ON activities.id=time_slots.activity_id"
  
  def in_future?
    starts_at > Time.now
  end
  
  def in_past?
    starts_at < Time.now
  end
  
  def starts_at_time_string
    return nil if starts_at.nil? && time_slot.nil?
    @starts_at_time_string || (starts_at || time_slot.starts_at).strftime("%H:%M")
  end
  
  def starts_at_neat_string
    starts_at.strftime("%d %b at %H:%M")
  end
  
  def thank_you_mail
    ThankYouMail.new(:time_slot_booking => self)
  end
  
  def to_s
    "#{time_slot} on #{starts_at.strftime("%A %b %d at %H:%M")}"
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