MembersController.class_eval do
  
  member_only :big_print
  owner_only :agree_to_big_print
  
  skip_before_filter :redirect_to_organisation_terms, :only => %w{agree_to_big_print big_print}
  
  def agree_to_big_print
    @member = Member.find(params[:id])
    if @member.update_attributes(params[:member]) && @member.agreed_to_terms?
      render :action => "agree_to_big_print"
    else
      @member.errors.add(:agreed_to_terms, "you must agree to the terms")
      render :action => "big_print"
    end
  end
  
  def big_print
    @member = logged_in_member
  end
  
end