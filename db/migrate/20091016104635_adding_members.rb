class AddingMembers < ActiveRecord::Migration

  def self.up
    create_table :members, :force => true do |t|
      t.string :email, :default => "", :null => false
      t.string :username, :default => ""
      t.string :password, :limit => 25, :default => "", :null => false
      t.string :forename, :limit => 25, :default => "", :null => false
      t.string :surname, :limit => 25, :default => "", :null => false
      t.boolean :is_admin, :default => false, :null => false
      t.text :bio
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :members
  end

end
