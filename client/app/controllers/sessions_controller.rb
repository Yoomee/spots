# Copyright 2011 Yoomee Digital Ltd.
# 
# This software and associated documentation files (the
# "Software") was created by Yoomee Digital Ltd. or its agents
# and remains the copyright of Yoomee Digital Ltd or its agents
# respectively and may not be commercially reproduced or resold
# unless by prior agreement with Yoomee Digital Ltd.
# 
# Yoomee Digital Ltd grants Spots of Time (the "Client") 
# the right to use this Software subject to the
# terms or limitations for its use as set out in any proposal
# quotation relating to the Work and agreed by the Client.
# 
# Yoomee Digital Ltd is not responsible for any copyright
# infringements caused by or relating to materials provided by
# the Client or its agents. Yoomee Digital Ltd reserves the
# right to refuse acceptance of any material over which
# copyright may apply unless adequate proof is provided to us of
# the right to use such material.
# 
# The Client shall not be permitted to sub-license or rent or
# loan or create derivative works based on the whole or any part
# of the Works supplied by us under this agreement without prior
# written agreement with Yoomee Digital Ltd.
SessionsController.class_eval do
  
  skip_before_filter :redirect_to_organisation_terms, :only => %w{destroy}

  def create_fb
    if request.xhr?
      if current_facebook_user
        @logged_in_member = Member.find_by_fb_user_id(current_facebook_user.id) || create_member_from_fb
        session[:logged_in_member_id] = @logged_in_member.id
        render :text => "success"
      else
        render :text => "failure"
      end
    else
      if current_facebook_user
        if @logged_in_member = Member.find_by_fb_user_id(current_facebook_user.id)
          login_member!(@logged_in_member)
        else
          @logged_in_member = create_member_from_fb
          session[:logged_in_member_id] = @logged_in_member.id
          redirect_after_signup
        end
      else
        redirect_hash = waypoint || {}
        redirect_to redirect_hash.merge(:denied_fb_perms => true)
      end
    end
  end

  private
  def create_member_from_fb
    current_facebook_user.fetch
    member = Member.find_or_initialize_by_email(current_facebook_user.email)
    member.update_attributes(:fb_user_id => current_facebook_user.id, :forename => current_facebook_user.first_name, :surname => current_facebook_user.last_name)
    member
  end

end