class CreateOrganisations < ActiveRecord::Migration
  def self.up
    create_table :organisations do |t|
      t.integer :member_id
      t.string :name
      t.text :description
      t.string :image_uid
      t.timestamps
    end
  end

  def self.down
    drop_table :organisations
  end
end