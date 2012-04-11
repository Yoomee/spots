class AddingFieldsToContentPages < ActiveRecord::Migration

  def self.up
    add_column :content_pages, :expires_on, :datetime, :default => Time.local(2035)
    add_column :content_pages, :publish_on, :datetime
  end

  def self.down
    remove_column :content_pages, :expires_on
    remove_column :content_pages, :publish_on
  end
  
end
