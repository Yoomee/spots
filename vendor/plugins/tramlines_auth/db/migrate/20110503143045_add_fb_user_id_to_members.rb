class AddFbUserIdToMembers < ActiveRecord::Migration
  
  def self.up
    add_column :members, :fb_user_id, :integer unless Member.column_names.include? "fb_user_id"
  end

  def self.down
    remove_column :members, :fb_user_id
  end
  
end
