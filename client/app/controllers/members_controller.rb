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
MembersController.class_eval do
  
  member_only :big_print
  owner_only :agree_to_big_print, :edit_bio, :update_bio
  
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
    @page = Page.slug(:big_print)
  end
  
  def create_with_auth
    @member = Member.new(params[:member])
    @member.generate_random_password(true) if logged_in_member_is_admin?
    if @member.save
      session[:logged_in_member_id] = @member.id if logged_out?
      if Module.value_to_boolean(params[:in_popup])
        render(:text => "<script type='text/javascript'>window.close()</script>")
      elsif logged_in_member_is_admin?
        flash[:notice] = "The account has been created."
        redirect_to_waypoint
      else
        redirect_after_signup
      end
    elsif @member.twitter_connected? || @member.facebook_connected? || @member.linked_in_connected?
      session[:auth_data] = nil
      case @member.auth_service
      when 'Facebook'
        session[:auth_data] = {:auth_service => 'Facebook', :auth_id => @member.fb_user_id}
      when 'Twitter'
        session[:auth_data] = {:auth_service => 'Twitter', :auth_id => @member.twitter_id, :auth_username => @member.twitter_username, :auth_token => @member.twitter_token, :auth_secret => @member.twitter_secret}
      when 'LinkedIn'
        session[:auth_data] = {:auth_service => 'LinkedIn', :auth_id => @member.linked_in_user_id, :auth_token => @member.linked_in_token, :auth_secret => @member.linked_in_secret}
      end
      @existing_member = Member.find_by_email(@member.email)
      render :template => 'sessions/register_email'
    else
      render :action => logged_in_member_is_admin?  ? 'new_by_admin' : 'new'
    end
  end
  
  def edit_bio
    @member = Member.find(params[:id])
    render :partial => "members/bio_form", :locals => {:member => @member}
  end
  
  def update_bio
    @member = Member.find(params[:id])    
    render :update do |page|
      if @member.update_attributes(params[:member])
        page.redirect_to(@member)
      else
        page[:member_bio_form].replace(render("members/bio_form", :member => @member))
      end
    end
  end
  
end