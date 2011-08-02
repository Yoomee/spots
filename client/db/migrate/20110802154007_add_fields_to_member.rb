class AddFieldsToMember < ActiveRecord::Migration
  
  def self.up
    add_column :members, :phone, :string
    add_column :members, :agreed_to_terms, :boolean, :default => false
  end

  def self.down
    remove_column :members, :agreed_to_terms
    remove_column :members, :phone
  end
  
end
