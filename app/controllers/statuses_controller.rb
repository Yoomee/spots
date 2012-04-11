class StatusesController < ApplicationController
  
  member_only :create
  owner_only :destroy, :edit
  
  def show
    @status = Status.find(params[:id])
  end
  
  def create
    @status = Status.new(params[:status])
    render :update do |page|
      if @status.save
        page["member_#{@status.member_id}_status"].replace render("statuses/status", :member => @status.member)   
        @status = @status.member.statuses.build
      end
      page["member_#{@status.member_id}_status_form"].replace render("statuses/form", :status => @status) 
    end
  end
  
  def destroy
    @status = Status.find(params[:id])
    @status.destroy
    flash[:notice] = "Successfully deleted status."
    redirect_to_waypoint_after_destroy
  end  
end
