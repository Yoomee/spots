class WallPost < ActiveRecord::Base
  
  belongs_to :member
  belongs_to :wall

  after_destroy :destroy_attachable_rating
  after_save :set_attachable_rating
  after_save :set_attachable_delta_flag

  validates_presence_of :member
  validates_presence_of :text, :message => "Please enter some text above."
  validates_presence_of :wall

  delegate :accepts_mail_response?, :to => :attachable, :prefix => true
  delegate :attachable, :to => :wall, :allow_nil => true
  delegate :attachable_id, :to => :wall, :allow_nil => true, :allow_nil => true
  delegate :attachable_type, :to => :wall, :allow_nil => true, :allow_nil => true
  delegate :full_name, :to => :member, :prefix => true
  delegate :mail_hash_for, :to => :attachable
  
  search_attributes %w{text}, :has => "wall_id", :autocomplete => false
  
  attr_accessor :rating_value, :rating_member_id
  
  def attachable_member
    return nil if attachable.nil?
    return attachable if attachable_type == "Member"
    attachable.respond_to?(:member) ? attachable.member : nil
  end
  
  def is_owner? member
    self.member == member
  end

  def other_members_who_posted
    wall.members_who_posted.not_including(self.member)
  end
  alias_method :other_members_who_commented, :other_members_who_posted
  
  def rating_value
    if !new_record? && attachable.is_rateable?
      attachable.rating_by(member).to_i
    else
      @rating_value ||= 3
    end
  end
  
  def summary_fields
    ["text"]
  end
  
  private
  def destroy_attachable_rating
    return true if attachable.nil? || !attachable.is_rateable?
    if member_rating = attachable.ratings.find_by_member_id(member.id)
      member_rating.destroy
    else
      true
    end
  end
  
  def set_attachable_delta_flag
    if attachable.respond_to?(:delta=)
      attachable.delta = true
      attachable.save
    else
      true
    end
  end

  def set_attachable_rating
    return true if attachable.nil? || !attachable.is_rateable? || rating_member_id.nil?
    attachable.add_rating_for!(Member.find_by_id(rating_member_id), @rating_value.to_i)
  end

end
