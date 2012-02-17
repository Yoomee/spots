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
class Organisation < ActiveRecord::Base
  
  include TramlinesImages
  
  belongs_to :member
  belongs_to :organisation_group
  has_many :time_slots, :dependent => :destroy
  has_many :time_slot_bookings, :through => :time_slots, :source => :bookings
  has_many :activities, :through => :time_slots, :uniq => true
  has_many :documents

  after_create :send_emails

  delegate :email, :to => :member

  has_location
  has_permalink

  validates_presence_of :name, :member, :location, :group_type, :phone
  
  accepts_nested_attributes_for :member
  
  named_scope :with_activity, lambda {|activity| {:joins => :activities, :conditions => {:activities => {:id => activity.id}}}}
  named_scope :visible, {:conditions => {:awake => true, :confirmed => true}}

  search_attributes %w{name description}

  def active?
    confirmed? && awake?
  end
  alias_method :visible?, :active?
  
  def activity_day_integers(activity)
    out = []
    TimeSlot::DAYS.each_with_index do |day, index|
      if day == :sun
        out << 0 if time_slots_for_activity(activity).any?(&:sun?)
      else
        out << index + 1 if time_slots_for_activity(activity).any? {|ts| ts.send(day)}
      end
    end
    out
  end
  
  def asleep?
    !awake?
  end
  
  def existing_bookings_for_activity(activity)
    date_strings = time_slot_bookings.for_activity(activity).starts_at_greater_than(num_weeks_notice.weeks.from_now).collect do |booking|
      time_slots_for_activity(activity).available_on_date(booking.starts_at).present? ? nil : booking.starts_at.strftime("%a %b %d %Y")
    end
    date_strings.reject(&:blank?)
  end
  
  def ordered_activities
    (activities.volunteering.available_to_organisation(self).ascend_by_name + Activity.volunteering.available_to_organisation(self).ascend_by_name).uniq
  end
  
  def next_available_date_for_activity(activity)
    days = %w{sun mon tue wed thu fri sat}
    date = num_weeks_notice.weeks.from_now.to_date
    soonest_date = nil
    until soonest_date.present?
      soonest_date = date if time_slots_for_activity(activity).available_on_date(date).present?
      date = date + 1.day
    end
    soonest_date
  end
  
  def status
    case
    when active?
      'active'
    when !confirmed?
      'unconfirmed'
    when asleep?
      'hidden'
    end
  end
  
  def time_slots_for_activity(activity)
    time_slots.activity_id_is(activity.id)
  end
  
  def to_s
    name
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
Organisation::GROUP_TYPES = ["Children up to 12", "Young people 12-19", "Older people 65+", "Carers", "People with learning disabilities", "People with health conditions"]
Organisation::SIZE_OPTIONS = ["0-30", "30-50", "50-100", "100+"]