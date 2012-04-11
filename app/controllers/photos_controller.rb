class PhotosController < ApplicationController
  
  member_only :create, :new
  owner_only :destroy, :edit, :update
  
  before_filter :get_photo_album, :only => %w{ajax index new}
  before_filter :get_photo, :only => %w{edit destroy show update}
  
  def ajax
    @photos = @photo_album.photos
    render(:partial => 'photos', :locals =>{:photos => @photos})
  end
  
  def create
    @photo = Photo.new(params[:photo])
    if @photo.save
      flash[:notice] = "Successfully created photo."
      redirect_to @photo
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @photo.destroy
    flash[:notice] = "Successfully deleted photo."
    redirect_to_waypoint_after_destroy
  end
  
  def edit
  end
  
  def index
    @photos = @photo_album ? @photo_album.photos : Photo.all
  end
  
  def new
    @photo = Photo.new(:member => @logged_in_member, :album => @photo_album)
  end
  
  def show
  end
  
  def update
    if @photo.update_attributes(params[:photo])
      flash[:notice] = "Successfully updated photo."
      redirect_to @photo
    else
      render :action => 'edit'
    end
  end
  
  private
  def get_photo
    @photo = Photo.find(params[:id])
  end
  
  def get_photo_album
    @photo_album = PhotoAlbum.find(params[:photo_album_id]) if params[:photo_album_id]
  end

end
