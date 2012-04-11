class AddLinkedInCredentials < ActiveRecord::Migration
  
  def self.up
    add_column :members, :linked_in_token, :string
    add_column :members, :linked_in_secret, :string
  end

  def self.down
    remove_column :members, :linked_in_token
    remove_column :members, :linked_in_secret
  end
  
end
