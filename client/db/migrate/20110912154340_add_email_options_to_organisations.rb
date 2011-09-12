class AddEmailOptionsToOrganisations < ActiveRecord::Migration
  
  def self.up
    add_column :organisations, :email_each_day, :boolean, :default => false
    add_column :organisations, :email_each_week, :boolean, :default => false
  end

  def self.down
    remove_column :organisations, :email_each_day
    remove_column :organisations, :email_each_week
  end
  
end
