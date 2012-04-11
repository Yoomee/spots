class AddHiddenToSections < ActiveRecord::Migration

  def self.up
    add_column :sections, :hidden, :boolean, :default => false
  end

  def self.down
    remove_column :sections, :hidden
  end

end
