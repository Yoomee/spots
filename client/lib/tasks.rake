namespace :spots do

  desc "Send daily emails of changes"
  task :daily_volunteer_updates => :environment do
    Organisation.email_each_day.select(&:volunteers_changed_in_past_day?).each do |organisation|
      puts "Sending daily volunteer list to #{organisation}"
      Notifier.deliver_daily_volunteer_list(organisation)
    end
  end
  
  desc "Send weekly emails of changes"
  task :weekly_volunteer_updates => :environment do
    Organisation.email_each_week.email_each_day.each do |organisation|
      puts "Sending weekly volunteer list to #{organisation}"
      Notifier.deliver_weekly_volunteer_list(organisation)
    end
  end
  
  desc "Send daily emails of passed activities"
  task :daily_passed_activities => :environment do
    TimeSlotBooking.with_activity.in_past_day.all.each do |booking|
      puts "Sending past activity emails for #{booking.id}"
      Notifier.deliver_activity_passed_volunteer(booking)
      Notifier.deliver_activity_passed_organisation(booking)
    end
  end
  
  desc "Send daily emails"
  task :daily => [:daily_volunteer_updates, :daily_passed_activities] do
  end
  
  desc "Send weekly emails"
  task :weekly => :weekly_volunteer_updates do
  end  
  
end