class AddPasswordGeneratedToMembers < ActiveRecord::Migration
  
  def self.up
    add_column :members, :password_generated, :boolean, :default => false
  end

  def self.down
    remove_column :members, :password_generated
  end
  
end
