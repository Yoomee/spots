class CreateMails < ActiveRecord::Migration
  
  def self.up
    create_table :mails do |t|
      t.integer :mailing_id
      t.integer :recipient_id
      t.string :subject
      t.string :from
      t.text :plain_body
      t.text :html_body
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :mails
  end
  
end
