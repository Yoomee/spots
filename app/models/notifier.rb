class Notifier < ActionMailer::Base

  helper :application, :links, :options_panel, :settings, :text, :members, :image

  # NOTE If the following is used (client templates for notifier) the whole directory must be copied to the client directory
  # if File.exists? "#{RAILS_ROOT}/client/app/views/notifier"
  #   Notifier.template_root = "#{RAILS_ROOT}/client/app/views"
  # end

  #TODO Views still need to copied into client to ensure correct MIME types.

  class << self
    def no_deliveries(&block)
      original_setting = ActionMailer::Base.perform_deliveries
      ActionMailer::Base.perform_deliveries = false
      begin
        yield
      ensure
        ActionMailer::Base.perform_deliveries = original_setting
      end
    end
  end

  def mail(mail)
    recipients mail.recipient_email    
    from mail.from
    subject mail.subject
    @mail = mail
    content_type "multipart/alternative"
    part :content_type => "text/plain", :body => render_message("mail.text.plain", {})
    part :content_type => "text/html", :body => render_message("mail.text.html", {})
  end

  def password_reminder member
    recipients member.email
    from APP_CONFIG['site_email']
    subject "Forgotten password"
    @member = member
    @login_hash = member.login_hashes.create(:expire_at => 1.day.from_now)
    content_type "multipart/alternative"    
    part :content_type => "text/plain", :body => render_message("password_reminder.text.plain", {})
    part :content_type => "text/html", :body => render_message("password_reminder.text.html", {})
  end

  def share_link model_instance, email_details
    recipients email_details[:recipient_email]
    from email_details[:email]
    subject "Thought you might be interested in this #{model_instance.class.name.to_s.downcase}"
    @body['email_details'] = email_details
    @body['model'] = model_instance
    content_type "multipart/alternative"    
    part :content_type => "text/plain", :body => render_message("share_link.text.plain", @body)
    part :content_type => "text/html", :body => render_message("share_link.text.html", @body)
  end

  def notifier_view_exists?(view_name)
    ApplicationController.view_paths.any? do |path|
      File.exists?("#{path}/#{view_name}.text.html.haml") || File.exists?("#{path}/#{view_name}.text.plain.haml")
    end
  end

end
