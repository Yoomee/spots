class AddMailFieldsToMailings < ActiveRecord::Migration
  
  def self.up
    add_column :mailings, :from, :string
    add_column :mailings, :html_body, :text
    add_column :mailings, :plain_body, :text
    add_column :mailings, :subject, :string
  end

  def self.down
    remove_column :mailings, :from
    remove_column :mailings, :html_body
    remove_column :mailings, :plain_body
    remove_column :mailings, :subject
  end
end
