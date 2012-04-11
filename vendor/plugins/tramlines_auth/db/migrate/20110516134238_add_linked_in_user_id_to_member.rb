class AddLinkedInUserIdToMember < ActiveRecord::Migration
  
  def self.up
    add_column :members, :linked_in_user_id, :string
  end

  def self.down
    remove_column :members, :linked_in_user_id
  end
  
end
