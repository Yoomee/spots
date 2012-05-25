class OrganisationGroup < ActiveRecord::Base
  include TramlinesImages
  
  validates_presence_of :name
  
  has_many :activities, :through => :organisations
  has_many :organisations, :dependent => :nullify
  has_many :group_specific_activities, :class_name => "Activity"
  has_many :all_time_slot_questions, :dependent => :destroy
  has_many :time_slot_questions, :conditions => {:deleted_at => nil}

  accepts_nested_attributes_for :time_slot_questions

  has_permalink
  
  named_scope :with_activities, :joins => "INNER JOIN organisations ON (organisations.organisation_group_id = organisation_groups.id) INNER JOIN time_slots ON (time_slots.organisation_id = organisations.id) ", :group => 'organisation_groups.id'

  class << self

    def find_by_ref(ref)
      return nil if ref.blank?
      ref += "=" * (( 4 - (ref.length % 4)) % 4)
      find_by_id(Base64.decode64(ref).to_i - 1000)
    end

    def for_get_involved
      with_activities.without_id_in(1)      
    end
    
  end

  def activities
    Activity.for_organisation_group(self)
  end
  
  def ref
    Base64.encode64((id+1000).to_s).strip.sub(/\=*$/,'')
  end
  
end