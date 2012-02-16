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
ApplicationController.class_eval do

  include Facebooker2::Rails::Controller
  
  before_filter :redirect_to_organisation_terms
  
  def redirect_to_organisation_terms
    return true if logged_out? || logged_in_member.agreed_to_terms? || logged_in_member.organisations.empty? || logged_in_member.force_password_change?
    return redirect_to(big_print_path)
  end
  
  protected
  def redirect_after_signup
    flash[:registered] = "Hi #{logged_in_member.forename}, welcome to #{APP_CONFIG['site_name']}."
    redirect_to home_path
  end
  
end