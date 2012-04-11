class ChangeAttachableTypeToStringInLocations < ActiveRecord::Migration
  def self.up
    change_column :locations, :attachable_type, :string
  end

  def self.down
    change_column :locations, :attachable_type, :integer    
  end
end
