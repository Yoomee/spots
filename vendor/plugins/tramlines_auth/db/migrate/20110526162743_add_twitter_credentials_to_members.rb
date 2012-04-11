class AddTwitterCredentialsToMembers < ActiveRecord::Migration
  
  def self.up
    add_column :members, :twitter_token, :string
    add_column :members, :twitter_secret, :string
  end

  def self.down
    remove_column :members, :twitter_token
    remove_column :members, :twitter_secret
  end
  
end
