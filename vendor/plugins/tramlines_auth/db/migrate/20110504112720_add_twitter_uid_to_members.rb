class AddTwitterUidToMembers < ActiveRecord::Migration
  
  def self.up
    add_column :members, :twitter_id, :integer
  end

  def self.down
    remove_column :members, :twitter_id
  end
  
end
