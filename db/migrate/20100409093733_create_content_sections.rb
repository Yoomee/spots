class CreateContentSections < ActiveRecord::Migration

  def self.up
    create_table :content_sections do |t|
      t.integer :parent_id
      t.string :name
      t.integer :weight, :default => 0
      t.string :view, :default => 'normal'
    end
  end

  def self.down
    drop_table :content_sections
  end

end
