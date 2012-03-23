MembersReport.class_eval do
  
  fields :email, :username, :surname, :forename, :user_type, :created_at, :updated_at

end

MembersReport::Row.class_eval do

  def_delegator :@member, :user_type

end

