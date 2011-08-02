class AddFieldsToOrganisations < ActiveRecord::Migration
  def self.up
    change_table :organisations do |t|
      t.integer :num_weeks_notice, :default => 2
      t.boolean :volunteers_insured, :default => false
      t.boolean :require_crb, :default => false
      t.text :terms
      t.boolean :active, :default => false
    end
  end

  def self.down
    change_table :organisations do |t|
      t.remove :num_weeks_notice
      t.remove :volunteers_insured
      t.remove :require_crb
      t.remove :terms
      t.remove :active
    end
  end
end
