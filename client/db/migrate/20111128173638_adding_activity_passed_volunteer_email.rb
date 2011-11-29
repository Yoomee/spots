class AddingActivityPassedVolunteerEmail < ActiveRecord::Migration

  def self.up
    Mailing.create!(
      {:name => 'activity_passed_volunteer',
      :subject => 'Activity Passed - {activity_name}',
      #:plain_body => PLAIN_BODY,
      :html_body => HTML_BODY
      }
    )
  end

  def self.down
    Mailing.find_by_name('activity_passed_volunteer').destroy
  end
  
end

AddingActivityPassedVolunteerEmail::HTML_BODY = <<EOS
<p>
  Dear {volunteer_forename},
</p>
<p>
  We have noticed that the activity {activity_name} on {activity_date} at {activity_time} has recently taken place.
</p>
<p>
  We would really appreciate it if you would click <a href='http://spotsoftime.wufoo.com/forms/so-how-did-it-go/'>here</a> to fill in a short questionnaire about the activity.
</p>
<p>
  Thank you,
  <br />
  Spots of Time
</p>
EOS

