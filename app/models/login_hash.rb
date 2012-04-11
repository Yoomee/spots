class LoginHash < ActiveRecord::Base
  
  belongs_to :member
  
  validates_presence_of :member_id, :salt, :long_hash
  
  def after_initialize
    self.salt ||= Member::generate_password
    self.long_hash ||= ActiveSupport::SecureRandom.hex(10)
  end
  
  def expired?
    !expire_at.nil? && expire_at < Time.now
  end
  
  def hash
    Digest::MD5.hexdigest("#{salt}#{long_hash}")
  end
  
end