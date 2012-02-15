class OrganisationGroup < ActiveRecord::Base
  include TramlinesImages
  
  validates_presence_of :name
  
  has_many :organisations, :dependent => :nullify

  def activities
    Activity.for_organisation_group(self)
  end
  
end