class CreatingEnquiries < ActiveRecord::Migration
  
  def self.up    
    create_table :enquiry_fields do |t|
      t.integer :enquiry_id
      t.string :name
      t.text :value
      t.timestamps
    end

    create_table :enquiries do |t|
      t.string :form_name
      t.integer :member_id
      t.timestamps
    end
  end

  def self.down
    drop_table :enquiry_fields
    drop_table :enquiries
  end
  
end