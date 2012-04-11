class AddLinkedInProfileUrlToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :linked_in_profile_url, :text
  end

  def self.down
    remove_column :members, :linked_in_profile_url
  end
end
