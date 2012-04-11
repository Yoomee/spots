# Used for the purpose of ActiveRecord validations, but without a database table. 
# E.g. Share - We need to check the format of the email addresses and presence of name and email addresses.
class Tableless < ActiveRecord::Base
  
  def self.columns
    @columns ||= [];
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  # Override the save method to prevent exceptions.
  def save(validate = true)
    validate ? valid? : true
  end
  
end
