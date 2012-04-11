class AddingContentPages < ActiveRecord::Migration

  def self.up
    create_table :content_pages do |t|
      t.integer :section_id
      t.string :title
      t.text :intro
      t.text :text
      t.timestamps
    end
  end

  def self.down
    drop_table :content_pages
  end
  
end
