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
Member.class_eval do
  
  has_many :organisations, :dependent => :nullify
  has_many :time_slot_bookings, :dependent => :destroy
    
  has_wall
  
  validates_numericality_of :phone, :allow_blank => true
  
  class << self
    
    def anna
      Member.find_by_email("anna@spotsoftime.org.uk")
    end
    
  end
  
  def future_time_slots
    time_slot_bookings.starts_at_gt(Time.now).ascend_by_starts_at
  end
  
  def past_time_slots
    time_slot_bookings.starts_at_lt(Time.now).descend_by_starts_at
  end
  
  def role
    case
    when is_admin?
      "admin"
    when organisations.present?
      "organisation owner"
    else
      "member"
    end      
  end
  
end