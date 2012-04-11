class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :lat
      t.string :lng
      t.string :address1
      t.string :address2
      t.string :city
      t.string :country
      t.string :postcode
      t.integer :attachable_id
      t.integer :attachable_type
      t.timestamps
    end
  end
  
  def self.down
    drop_table :locations
  end
end
