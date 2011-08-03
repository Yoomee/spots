ApplicationController.class_eval do
  
  before_filter :redirect_to_organisation_terms
  
  def redirect_to_organisation_terms
    return true if logged_out? || logged_in_member.agreed_to_terms? || logged_in_member.organisations.empty? || logged_in_member.force_password_change?
    return true if controller_name=="time_slots" && action_name=="index" && !params[:signup]
    return redirect_to(big_print_path)
  end
  
end