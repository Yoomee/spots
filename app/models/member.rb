class Member < ActiveRecord::Base
  
  include TramlinesImages

  YOOMEE_EMAILS = %w{andy@yoomee.com nicola@yoomee.com si@yoomee.com rich@yoomee.com ian@yoomee.com rob@yoomee.com matt@yoomee.com support@yoomee.com}
  PASSWORD_WORDS = %w{biz money moon blue win gold harp igloo june king lemon mini noon king push queen root sun trick red vocal wheel xray yoyo zebra}

  has_many :documents, :dependent => :destroy
  has_many :document_folders, :through => :documents, :source => :folder, :uniq => true
  has_many :links, :dependent => :destroy
  has_many :photo_albums, :as => :attachable, :dependent => :destroy
  has_many :photos, :through => :photo_albums, :dependent => :destroy
  has_many :statuses, :dependent => :destroy
  has_many :videos, :dependent => :destroy
  has_many :login_hashes
  has_many :news_feed_items, :as => :attachable, :dependent => :destroy

  named_scope :alphabetically, :order => "surname, forename"
  named_scope :distinct, :select => "DISTINCT members.*"
  named_scope :not_member, lambda{|member| {:conditions => ["members.id != ?", member.try(:id)]}}
  named_scope :with_bio, :conditions => "members.bio IS NOT NULL AND members.bio != ''"
  named_scope :with_ip_address, :conditions => "members.ip_address IS NOT NULL AND members.ip_address != ''"
  named_scope :admin, :conditions => {:is_admin => true}
  named_scope :non_admin, :conditions => {:is_admin => false}
  
  before_validation_on_create :generate_random_password
  validates_confirmation_of :password, :if => Proc.new{|member| !member.password_generated && member.changed.include?('password')}
  validates_email_format_of :email, :allow_blank => true
  validates_presence_of :forename, :password, :surname
  validates_uniqueness_of :email, :allow_blank => true, :case_sensitive => false
  validates_uniqueness_of :username, :allow_blank => true
  
  validates_each :surname do |record, attr, value|
    record.errors.add(attr, 'must be different from your first name') if value == record.forename && !value.blank?
  end

  attr_boolean_accessor :allow_username_instead_of_email, :dont_generate_password

  if site_uses_fb_connect?
    validates_presence_of :email, :unless => Proc.new{|m| m.fb_connected? || m.allow_username_instead_of_email?}
    validates_presence_of :username, :if => Proc.new {|m| !m.fb_connected? && m.email.blank? && m.allow_username_instead_of_email?}    
  else
    validates_presence_of :email, :unless => :allow_username_instead_of_email?
    validates_presence_of :username, :if => Proc.new {|m| m.email.blank? && m.allow_username_instead_of_email?}
  end

  # Overriding indexes doesn't work, so we need a get-out-clause if we want different attributes.
  # Setting CUSTOMIZED_MEMBER_INDEXES to true in a client initializer will then allow us to customize in the client version
  search_attributes %w{forename surname email username bio}, :autocomplete => %w{forename surname username} unless CUSTOMIZED_MEMBER_INDEXES == true

  add_to_news_feed

  has_permalink :auto_update => true

  class << self
  
    # Check if member can login
    def authenticate(email_or_username, password)
      return nil if email_or_username.blank?
      member = find_by_email_or_username(email_or_username)
      if member && member.password == password
        return member
      else
        return nil
      end
    end
    
    def authenticate_from_hash(login_hash_id, hash)
      if login_hash = LoginHash.find_by_id(login_hash_id)
        if hash == login_hash.hash && !login_hash.expired?
          return login_hash.member
        end
      end
      nil
    end
    
    def find_by_email_or_username(email_or_username)
      find :first, :conditions => ["email=? OR username=?", email_or_username, email_or_username]
    end

    def exists_with_username?(username)
      exists? :username => username
    end

    def generate_password
      "#{PASSWORD_WORDS.rand}#{PASSWORD_WORDS.rand}#{rand(100)}"
    end
    
    def generate_valid_username(requested, distinguisher = nil)
      username = "#{requested}#{distinguisher}"
      exists_with_username?(username) ? generate_valid_username(requested, (distinguisher ||= 0) + 1) : username
    end

  end
  
  def email=(val)
    val = val.strip if val.is_a?(String)
    write_attribute(:email, val)
  end
  
  def force_password_change?
    !fb_connected? && password_generated?
  end
  
  def fb_connected?
    respond_to?(:fb_user_id) && !fb_user_id.blank?
  end
  
  # Gets the full name of the member
  def full_name
    case
    when forename.present? && surname.present?
      "#{forename} #{surname}"
    when forename.present?
      forename
    when email.present?
      email
    else
      ''
    end
  end

  def full_name=(val)
    names = val.split(" ")
    self.surname = names.pop
    self.forename = names.join(" ")
  end

  def yoomee_staff?
    email.in?(YOOMEE_EMAILS)
  end

  def password=(value)
    self.password_generated = false
    write_attribute(:password, value)
  end

  def status
    statuses.latest.limit(1).first
  end
  
  def to_s
    full_name
  end

  def generate_random_password(force = false)
    if !dont_generate_password? && (password.blank? || force)
      self.password = self.class::generate_password
      self.password_generated = true
    end
  end

end

