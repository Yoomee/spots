class AddingMemberships < ActiveRecord::Migration

  def self.up
    create_table :memberships do |t|
      t.integer :member_id, :null => false
      t.integer :group_id, :null => false
      t.string :group_type, :null => false
    end
  end

  def self.down
  end

end
