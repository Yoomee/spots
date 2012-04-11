class ChangeWallPostTextFromStringToText < ActiveRecord::Migration
  def self.up
    change_column :wall_posts, :text, :text
  end

  def self.down
    change_column :wall_posts, :text, :string
  end
end
