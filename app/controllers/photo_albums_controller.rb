class PhotoAlbumsController < ApplicationController
  
  member_only :create, :index, :new
  owner_only :edit, :destroy, :update 
  admin_only :index
  
  admin_link 'Photo albums', :index
  admin_link 'Photo albums', :new

  before_filter :get_attachable, :only => %w{new}
  
  def index
    @system_albums = PhotoAlbum.system_albums
  end
  
  def new
    @photo_album = PhotoAlbum.new(:attachable => @attachable, :system_album => admin_logged_in?)
  end
  
  def create
    @photo_album = PhotoAlbum.new(params[:photo_album])
    if @photo_album.save
      flash[:notice] = "Successfully created photo album."
      redirect_to photo_album_photos_path(@photo_album)
    else
      render :action => 'new'
    end
  end
  
  def edit
    @photo_album = PhotoAlbum.find(params[:id])
  end
  
  def update
    @photo_album = PhotoAlbum.find(params[:id])
    if @photo_album.update_attributes(params[:photo_album])
      flash[:notice] = "Successfully updated photo album."
      redirect_to photo_album_photos_path(@photo_album)
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @photo_album = PhotoAlbum.find(params[:id])
    @photo_album.destroy
    flash[:notice] = "Successfully deleted photo album."
    if @photo_album.attachable
      redirect_to attachable_photo_albums_path(@photo_album.attachable)
    else
      redirect_to photo_albums_url
    end
  end
  
  def show
    redirect_to photo_album_photos_path(params[:id])
  end
  
  private  
  def get_attachable
    begin
      if params[:attachable_id]
        attachable_class = request.request_uri.match(/\/(\w+)\/\w+\/photo_albums/)[1].singularize.capitalize.constantize
        @attachable = attachable_class.find(params[:attachable_id])
      else
        @attachable = @logged_in_member
      end
    rescue
    end
  end
  
end
