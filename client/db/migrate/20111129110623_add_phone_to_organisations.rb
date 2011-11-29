class AddPhoneToOrganisations < ActiveRecord::Migration
  
  def self.up
    add_column :organisations, :phone, :string
  end

  def self.down
    remove_column :organisations, :phone
  end
  
end
