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
class TimeSlot < ActiveRecord::Base
  
  belongs_to :activity
  belongs_to :organisation
  has_many :bookings, :class_name => "TimeSlotBooking", :dependent => :destroy
  
  validates_presence_of :activity, :organisation, :starts_at, :ends_at
  validates_order_of :starts_at, :ends_at
  validate :presence_of_days
  validate :date_in_future
  #before_validation :set_day_from_date

  delegate :description, :name, :email, :to => :organisation, :prefix => true
  delegate :has_lat_lng?, :lat_lng, :lat, :lng, :num_weeks_notice, :to => :organisation
  delegate :name, :to => :activity, :prefix => true

  named_scope :after, lambda {|date| {:conditions => ["DATE(time_slots.date) > :date", {:date => date}]}}
  named_scope :available_on_date, lambda {|date| {:conditions => ["(DATE(time_slots.date) = :date OR #{date.strftime("%a").downcase} = 1) AND NOT EXISTS (SELECT id FROM time_slot_bookings WHERE time_slot_bookings.time_slot_id = time_slots.id AND DATE(time_slot_bookings.starts_at) = :date LIMIT 1)", {:date => date.to_date}]}}
  named_scope :confirmed, :joins => :organisation, :conditions => {:organisations => {:confirmed => true}}
  named_scope :group_by_organisation, :group => "time_slots.organisation_id"
  named_scope :for_organisation_group, lambda {|organisation_group| {:joins => :organisation, :conditions => ["organisations.organisation_group_id=?", organisation_group.id], :group => "time_slots.id"}}
  named_scope :one_off, :conditions => "date IS NOT NULL"

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
  
  def one_off?
    date.present?
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
  def date_in_future
    errors.add_to_base("Please select a date in the future") if date.present? && date < Date.today
  end
  
  def presence_of_days
    errors.add_to_base("Please select at least one day of the week") if TimeSlot::DAYS.all? {|d| !send(d)} && date.blank?
  end
  
  # def set_day_from_date
  #   return true if date.blank?
  #   wday = (date.wday - 1) % 7
  #   TimeSlot::DAYS.each_with_index do |d,idx|
  #     send("#{d}=", idx == wday)
  #   end
  # end
  
end

TimeSlot::DAYS = [:mon, :tue, :wed, :thu, :fri, :sat, :sun]
