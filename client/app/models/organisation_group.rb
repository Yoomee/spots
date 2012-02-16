class OrganisationGroup < ActiveRecord::Base
  include TramlinesImages
  
  validates_presence_of :name
  
  has_many :organisations, :dependent => :nullify

  class << self
    def find_by_ref(ref)
      return nil if ref.blank?
      ref += "=" * (( 4 - (ref.length % 4)) % 4)
      find_by_id(Base64.decode64(ref).to_i - 1000)
    end
  end

  def activities
    Activity.for_organisation_group(self)
  end
  
  def ref
    Base64.encode64((id+1000).to_s).strip.sub(/\=*$/,'')
  end
  
end