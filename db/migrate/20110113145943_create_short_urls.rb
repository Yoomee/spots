class CreateShortUrls < ActiveRecord::Migration
  def self.up
    create_table :short_urls do |t|
      t.text :long
      t.text :short
    end
  end

  def self.down
    drop_table :short_urls
  end
end
