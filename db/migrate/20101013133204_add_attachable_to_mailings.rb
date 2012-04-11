class AddAttachableToMailings < ActiveRecord::Migration
  
  def self.up
    change_table :mailings do |t|
      t.belongs_to :attachable, :polymorphic => true
    end
  end

  def self.down
    remove_column :mailings, :attachable_type, :string
    remove_column :mailings, :attachable_id, :integer
  end
  
end
