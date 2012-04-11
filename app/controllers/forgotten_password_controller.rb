class ForgottenPasswordController < ApplicationController
  
  open_actions :new, :create
  
  def create
    render :update do |page|
      if member = Member.find_by_email(params[:email])
        Notifier.deliver_password_reminder(member)
        page[:forgotten_password_wrapper].replace_html(render("success"))
      else
        page[:forgotten_password_box].replace(render("form", :error => true, :email => params[:email]))
      end
    end
  end
  
  def new
    render :partial => "form", :locals => {:error => false, :email => ""}
  end
  
end