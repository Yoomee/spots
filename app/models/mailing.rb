class Mailing < ActiveRecord::Base
  
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include ::TextHelper

  after_save :send_emails!, :if => :send_emails_after_save?

  belongs_to :attachable, :polymorphic => true
  
  has_many :mails, :autosave => true
  has_many :sent_mails, :class_name => 'Mail', :conditions => {:status => 'sent'}
  has_many :unsent_mails, :class_name => 'Mail', :conditions => {:status => 'not_sent'}
  
  validates_presence_of :subject, :html_body, :from
  
  attr_boolean_accessor :send_emails_after_save
  attr_accessor :worker_uid
  
  class << self
    
    # Needed by TextHelper
    def full_sanitizer
      @full_sanitizer ||= HTML::FullSanitizer.new
    end
    
  end
  
  def html_or_plain_body
    html_body.blank? ? plain_body : html_body
  end
  
  def html_body
    body = read_attribute(:html_body)
    return body unless body.blank?
    read_attribute(:plain_body).blank? ? '' : simple_format(plain_body)
  end
  
  def initialize(attributes = {})
    attributes[:from] ||= APP_CONFIG['site_email']
    super
  end
  
  def not_sent?
    status == 'not_sent'
  end
  
  def plain_body
    body = read_attribute(:plain_body)
    return body unless body.blank?
    read_attribute(:html_body).blank? ? '' : simple_unformat(html_body)
  end
  
  def recipients=(value)
    @recipients = value
  end
  
  def recipients
    return @recipients if !@recipients.nil?
    return (@recipients = Member.all) if attachable.nil?
    @recipients = attachable.respond_to?(:recipients_for_mailing) ? attachable.recipients_for_mailing : attachable.members
  end
  
  def send_emails!
    if send_emails_after_save? || ((!new_record? && !changed?) || save!)
      create_mails
      self.worker_uid = MailWorker.async_send_mailing(:mailing_id => id)
      # unsent_mails.each(&:send_email!)
    end
  end
  
  def sent?
    status == "all_sent"
  end
  
  def status
    return "not_sent" if mails.empty?
    if mails.exists?(["status = 'sent' OR status = 'resent' OR status = 'read'"])
      mails.exists?(["status = 'not_sent'"]) ? "some_sent" : "all_sent"
    else
      "not_sent"
    end
  end
  
  private
  def create_mails
    recipients.each do |member|
      mails.create(:recipient => member, :status => 'not_sent') unless mails.exists?(:recipient_id => member.id)
    end
  end
  
end