class VideosController < ApplicationController
  
  member_only :create, :new
  owner_only :edit, :destroy, :update
  
  before_filter :get_member, :only => %w{index}
  
  def index
    @videos = @member ? @member.videos : Video.all
  end
  
  def show
    @video = Video.find(params[:id])
    if request.xhr?
      render :text => @video.reformatted_html(:autoplay => true, :width => 600, :height => 400)
    end
  end
  
  def new
    @video = Video.new(:member => @logged_in_member)
  end
  
  def create
    @video = Video.new(params[:video])
    if @video.save
      flash[:notice] = "Successfully created video."
      redirect_to @video
    else
      render :action => 'new'
    end
  end
  
  def edit
    @video = Video.find(params[:id])
  end
  
  def update
    @video = Video.find(params[:id])
    if @video.update_attributes(params[:video])
      flash[:notice] = "Successfully updated video."
      redirect_to @video
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @video = Video.find(params[:id])
    @video.destroy
    flash[:notice] = "Successfully deleted video."
    redirect_to_waypoint_after_destroy
  end
  
  private
  def get_member
    @member = Member.find(params[:member_id]) if params[:member_id]
  end
  
end
