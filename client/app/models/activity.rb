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
class Activity < ActiveRecord::Base

  include TramlinesImages

  has_many :documents, :dependent => :destroy
  has_many :organisations, :through => :time_slots
  has_many :time_slots, :dependent => :destroy
  
  belongs_to :organisation_group
  
  validates_presence_of :name

  default_scope :order => "weight, created_at DESC"
  
  has_permalink
  
  search_attributes %w{name description}

  named_scope :anytime, :conditions => {:activity_type => "anytime"}
  named_scope :confirmed, :joins => :organisation, :conditions => {:organisation => {:confirmed => true}}
  named_scope :volunteering, :conditions => {:activity_type => "volunteering"}
  named_scope :available_to_organisation_with_group, lambda {|organisation|{:conditions => ["activities.organisation_group_id = ?", organisation.organisation_group_id]}}
  named_scope :non_group_specific, {:conditions => "activities.organisation_group_id IS NULL"}
  named_scope :for_organisation_group, lambda {|organisation_group| {
      :joins => (organisation_group ? :organisations : nil), 
      :conditions => (organisation_group ? ["organisations.organisation_group_id=?", (organisation_group.is_a?(OrganisationGroup) ? organisation_group.id : organisation_group)] : nil), 
      :group => "activities.id"}
  }
  named_scope :bookings_available_on_date, lambda {|date| {:joins => :time_slots, :conditions => ["(DATE(time_slots.date) = :date OR #{date.strftime("%a").downcase} = 1) AND NOT EXISTS (SELECT id FROM time_slot_bookings WHERE time_slot_bookings.time_slot_id = time_slots.id AND DATE(time_slot_bookings.starts_at) = :date LIMIT 1)", {:date => date.to_date}], :group => 'activities.id'}}
  
  named_scope :for_organisation_group_with_bookings_availaible_on_date, lambda {|organisation_group_id, date| {
      :joins => :organisations,
      :conditions => ["#{organisation_group_id.to_s.is_number? ? 'organisations.organisation_group_id = :group_id' : 'organisations.organisation_group_id IS NULL'}#{date ? " AND (DATE(time_slots.date) = :date OR #{date.strftime("%a").downcase} = 1) AND NOT EXISTS (SELECT id FROM time_slot_bookings WHERE time_slot_bookings.time_slot_id = time_slots.id AND DATE(time_slot_bookings.starts_at) = :date LIMIT 1)" : ""}", {:date => date.try(:to_date), :group_id => organisation_group_id}],
      :group => "activities.id"}
  }

  class << self
    
    def available_to_organisation(organisation)
      if organisation.organisation_group
        available_to_organisation_with_group(organisation)
      else
        non_group_specific
      end
    end
    
  end

  def anytime?
    activity_type == 'anytime'
  end

end
Activity::TYPES = %w{volunteering anytime}