class DropMemberships < ActiveRecord::Migration
  def self.up
    if table_exists?(:memberships)
      drop_table :memberships
    end
  end

  def self.down
    create_table :memberships do |t|
      t.integer :member_id, :null => false
      t.integer :group_id, :null => false
      t.string :group_type, :null => false
    end
  end
end
