class AddTwitterUsernameToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :twitter_username, :string
  end

  def self.down
    remove_column :members, :twitter_username
  end
end
