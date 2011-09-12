namespace :spots do

  desc "Send daily emails of changes"
  task :daily_volunteer_updates => :environment do
    Organisation.email_each_day.select(&:volunteers_changed_in_past_day?).each do |organisation|
      Notifier.deliver_daily_volunteer_list(organisation)
    end
  end
  
end