class AddDeltaToMembers < ActiveRecord::Migration
  def self.up
    add_column :members, :delta, :boolean, :default => true, :null => true
  end

  def self.down
    remove_column :members, :delta
  end
end
