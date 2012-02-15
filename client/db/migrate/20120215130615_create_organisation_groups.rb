class CreateOrganisationGroups < ActiveRecord::Migration
  def self.up
    create_table :organisation_groups do |t|
      t.string :name
      t.text :description
      t.string :image_uid
      t.timestamps
    end
  end

  def self.down
    drop_table :organisation_groups
  end
end
