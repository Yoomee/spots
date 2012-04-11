class CreateLoginHashes < ActiveRecord::Migration
  def self.up
    create_table :login_hashes do |t|
      t.integer :member_id
      t.string :salt
      t.string :long_hash
      t.datetime :expire_at 
    end
  end

  def self.down
    drop_table :login_hashes
  end
end
