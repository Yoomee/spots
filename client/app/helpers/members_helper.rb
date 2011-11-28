MembersHelper.module_eval do
  
  def member_type(member)
    case 
    when member.is_admin?
      'Admin'
    when member.organisations.present?
      'Organisation contact'
    else
      'Site member'
    end
  end
  
end