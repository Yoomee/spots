class MailWorker < Workling::Base

  def send_mailing(options)
    uid = options[:uid]
    mailing = Mailing.find(options[:mailing_id])
    mail_count = mailing.mails.size
        
    puts "\n\n#{Time.zone.now.to_s}\nSending mailing \"#{mailing.name}\" to #{mail_count} recipients."
    Workling.return.set(uid, {:sent => 0, :total => mail_count})
    
    mailing.mails.each_with_index do |mail, i|
      sleep(1) if RAILS_ENV == "development"
      mail.send_email!
      puts " - sent email #{i+1} of #{mail_count}."
      Workling.return.get(uid) #remove previous status to make current status latest.
      Workling.return.set(uid, {:sent => i+1, :total => mail_count})
    end
    puts "Finished."
  end
  
end