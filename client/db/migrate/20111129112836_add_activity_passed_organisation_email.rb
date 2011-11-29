class AddActivityPassedOrganisationEmail < ActiveRecord::Migration

  def self.up
    Mailing.create!(
      {:name => 'activity_passed_organisation',
      :subject => 'Activity Passed - {activity_name}',
      #:plain_body => PLAIN_BODY,
      :html_body => HTML_BODY
      }
    )
  end

  def self.down
    Mailing.find_by_name('activity_passed_organisation').destroy
  end

end

AddActivityPassedOrganisationEmail::HTML_BODY = <<EOS
<p>
  Dear {organisation_name},
</p>
<p>
  We hope you enjoyed receiving {volunteer_full_name} as a Spots of Time volunteer yesterday. It's important to us that people keep to their commitments so if you could click <a href='{confirm_placement_url}'>here</a> to confirm that this placement took place here we'd be very grateful.  It will also help {volunteer_forename} start to build up their volunteering profile with us.
</p>
<p>
  (And if you'd like to add a personal thank you to {volunteer_forename} too then just click <a href='{thank_you_url}'>here</a>.)
</p>
<p>
  Thanks
  <br />
  The Spots of Time Team
</p>
EOS