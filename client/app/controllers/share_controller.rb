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
ShareController.class_eval do
  
  def create
    model_name = params[:model_name] 
    @model = model_name.camelize.constantize.find(params[:id])
    if logged_in_member
      params[:share][:email] = logged_in_member.email
      params[:share][:name] = logged_in_member.full_name
    end
    @share = Share.new(params[:share])
    if @share.save
      Notifier.deliver_share_link @model, params[:share]
      flash[:notice] = "Thanks for sharing this #{model_name.to_s}"
      redirect_to @model
    else
      puts @share.errors.full_messages
      flash[:notice] = "There was an error sharing this #{model_name.to_s}. Please ensure you entered the requred details."
      render :action => "new"
    end
  end
  
end