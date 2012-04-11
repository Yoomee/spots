class ChangeFbUserIdToString < ActiveRecord::Migration
  def self.up
    change_column :members, :fb_user_id, :string
  end

  def self.down
    change_column :members, :fb_user_id, :integer
  end
end
