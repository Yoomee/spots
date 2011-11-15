class ChangeNumWeeksNoticeDefaultToOne < ActiveRecord::Migration
  
  def self.up
    change_column :organisations, :num_weeks_notice, :integer, :default => 1
    Organisation.find_all_by_num_weeks_notice(2).each do |organisation|
      organisation.update_attribute(:num_weeks_notice, 1)
    end
  end

  def self.down
    # Do nothing
  end
  
end
