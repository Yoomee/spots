class AddingWeightToPages < ActiveRecord::Migration

  def self.up
    add_column :pages, :weight, :integer, :default => 0
  end

  def self.down
    remove_column :pages, :weight
  end
  
end
