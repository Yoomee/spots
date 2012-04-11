class AddIpAddressToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :ip_address, :string
  end

  def self.down
    remove_column :members, :ip_address
  end
end
