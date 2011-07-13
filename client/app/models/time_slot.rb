class TimeSlot < ActiveRecord::Base
  
  belongs_to :activity
  belongs_to :organisation
  
  validates_presence_of :activity, :organisation, :starts_at, :ends_at
  validate :presence_of_days
  
  def ends_at_string
    @ends_at_string || "%02d:00" % (ends_at.try(:hour) || 5)
  end
  
  def ends_at_string=(value)
    @ends_at_string = value
    self.ends_at = Time.parse("2000-01-01 #{value}")
  end
  
  def starts_at_string
    @starts_at_string || "%02d:00" % (starts_at.try(:hour) || 9)
  end
  
  def starts_at_string=(value)
    @starts_at_string = value
    self.starts_at = Time.parse("2000-01-01 #{value}")
  end  
  
  private
  def presence_of_days
    errors.add_to_base("Please select at least one day of the week") if TimeSlot::DAYS.all? {|d| !send(d)}
  end
  
end

TimeSlot::DAYS = [:mon, :tue, :wed, :thu, :fri, :sat, :sun]