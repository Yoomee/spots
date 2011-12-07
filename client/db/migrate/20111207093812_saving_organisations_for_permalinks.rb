class SavingOrganisationsForPermalinks < ActiveRecord::Migration
  
  def self.up
    Organisation.all.each do |organisation|
      organisation.send :setup_permalink
      organisation.permalink.save!
    end
  end

  def self.down
    # Do nothing
  end
  
end
