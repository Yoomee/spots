# Used in Associate Babble
# TODO: move to vendor/plugins/tramlines_page_notifications when workers can work from plugins
class PageNotificationsWorker < Workling::Base
  def send_emails(options)
    if options[:page]
      options[:page].send_email_to_members!      
    else
      Page.need_to_send_email.each do |page|
        page.send_email_to_members!
      end
    end
  end  
end