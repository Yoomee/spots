class TimeSlot < ActiveRecord::Base
  
  belongs_to :activity
  belongs_to :organisation
  
  validates_presence_of :activity, :organisation, :starts_at, :ends_at
  
end

TimeSlot::DAYS = [:mon, :tue, :wed, :thu, :fri, :sat, :sun]