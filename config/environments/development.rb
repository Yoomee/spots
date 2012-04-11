# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

config.reload_plugins = true

config.gem 'forgery'


gitconfig_path = File.expand_path("~#{ENV['USER']}/.gitconfig")
if File.exists?(gitconfig_path)
  gitconfig = File.new(gitconfig_path).read
  dev_email = (gitconfig.scan(/email = (.*)$/)[0] || ['developers@yoomee.com']).first
else
  dev_email = 'developers@yoomee.com'
end


# for enabling emails in development mode
# config.action_mailer.perform_deliveries = true
# config.action_mailer.raise_delivery_errors = true
# 
config.action_mailer.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :sendmail

ActionMailer::Base.sendmail_settings = {
  :location       => '/usr/sbin/sendmail',
  :arguments      => '-i -t'
}

ActionMailer::Base.class_eval do

  def create_mail_with_development
    gitconfig_path = File.expand_path("~#{ENV['USER']}/.gitconfig")
    if File.exists?(gitconfig_path)
      gitconfig = File.new(gitconfig_path).read
      self.recipients = gitconfig.scan(/email = (.*)$/)[0] || ['developers@yoomee.com']
    else
      self.recipients = ['developers@yoomee.com']
    end
    self.bcc = []
    create_mail_without_development
  end
  alias_method_chain :create_mail, :development

end




