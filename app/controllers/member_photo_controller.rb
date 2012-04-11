class MemberPhotoController < ApplicationController

  before_filter :get_member

  def edit
  end
  
  def update
    if @member.update_attributes(params[:member])
      flash[:notice] = "Updated profile photo"
      redirect_to @member
    else
      render :action => "edit"
    end
  end

  private
  def get_member
    @member = Member.find(params[:member_id])    
  end

end