class TimeSlotQuestion < ActiveRecord::Base
  
  belongs_to :organisation_group
  
  has_many :time_slot_answers, :dependent => :destroy
  
  validates_presence_of :organisation_group, :text, :field_type, :unless => Proc.new {|question| question.new_record? && question.delete_this?}
  
  before_save :set_deleted_at
  
  attr_boolean_accessor :delete_this
  
  private
  def set_deleted_at
    if delete_this?
      time_slot_answers.empty? ? self.mark_for_destruction : self.deleted_at = Time.now
    end
  end
  
end