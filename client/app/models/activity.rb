class Activity < ActiveRecord::Base

  include TramlinesImages

  has_many :time_slots, :dependent => :destroy

  validates_presence_of :name

end