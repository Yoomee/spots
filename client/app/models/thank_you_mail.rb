class ThankYouMail

  include Validatable
  
  attr_accessor :time_slot_booking
  attr_writer :body, :subject

  validates_presence_of :subject, :body
  
  def attributes=(attrs = {})
    attrs.each do |k, v|
      send("#{k}=", v)
    end
  end

  def body
    @body || process_substitutions!(DEFAULT_BODY)
  end

  def errors
    @errors ||= ActiveRecord::Errors.new(self)
  end

  def from
    APP_CONFIG[:site_email]
  end
  
  def initialize(attrs = {})
    self.attributes = attrs
  end
  
  def recipients
    time_slot_booking.member_email
  end
  
  def subject
    @subject || process_substitutions!(DEFAULT_SUBJECT)
  end

  private
  def process_substitutions!(text)
    text = text.dup
    text.gsub!(/\{volunteer_forename\}/, time_slot_booking.member_forename)
    text.gsub!(/\{activity_name\}/, time_slot_booking.activity_name)
    text.gsub!(/\{activity_date\}/, time_slot_booking.starts_at.strftime("%A %B %d"))
    text.gsub!(/\{activity_time\}/, time_slot_booking.starts_at.strftime("%I:%M%p").downcase)
    text.gsub!(/\{organisation\}/, time_slot_booking.organisation_name)
    text
  end
  
end

ThankYouMail::DEFAULT_BODY = <<EOS
Dear {volunteer_forename},

Thank you for recently attending the {activity_name} activity on {activity_date} at {activity_time}. We really appreciate your hard work.

Regards,
The {organisation} Team
EOS

ThankYouMail::DEFAULT_SUBJECT = "Thank your for volunteering for {activity_name}"