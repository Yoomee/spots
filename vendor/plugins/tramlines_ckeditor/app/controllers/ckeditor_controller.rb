CkeditorController.class_eval do

  include ApplicationControllerConcerns::Permissions
  include ApplicationControllerConcerns::Preprocess
  include ApplicationControllerConcerns::Waypoints
  
  # TODO: change this back to admin_only. Big Mouth needed other permissions but couldn't chnage in client.
  member_only :create, :images

  append_before_filter :set_swf_file_post_name

  skip_before_filter :http_basic_authenticate
  
  helper :tramlines_ckeditor
  
#  unloadable
    
  # POST /ckeditor/create
  def create
    @kind = params[:kind] || 'file'
    
    @record = case @kind.downcase
      when 'file'  then AttachmentFile.new
			when 'image' then Photo.new(:system_photo => true)
	  end
	  
	  unless params[:CKEditor].blank?
	    params[@swf_file_post_name] = params.delete(:upload)
	  end
	  
    @record = Photo.new(:name => File.basename(params["Filename"]), 
                        :image => params[@swf_file_post_name],
                        :system_photo => true,
                        :member_id => @logged_in_member.id,
                        :photo_album_id => params[:album_id])
                        
    respond_to do |format|
      if @record.save
        @text = params[:CKEditor].blank? ? @record.to_json : %Q"<script type='text/javascript'>
              window.parent.CKEDITOR.tools.callFunction(#{params[:CKEditorFuncNum]}, '#{escape_single_quotes(@record.image.thumb('140x').url)}');
            </script>"
        format.html { render :text => @text }
        format.xml { head :ok }
      else
        format.html { render :nothing => true }
        format.xml { render :xml => @record.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # GET /ckeditor/images
  def images
    @target_field = params[:target_field]
    @albums = PhotoAlbum.system_albums # + @logged_in_member.photo_albums
    if @albums.empty?
      @album_id = nil
      @images = []
    else
      @album_id = @albums.first.id
      @images = @albums.first.photos.find(:all, :order=>"photos.id DESC")
    end
    respond_to do |format|
      format.html {}
      format.xml { render :xml=>@images }
    end
  end

  def update_images
    @album = PhotoAlbum.find(params[:id])
    @images = @album.photos.find(:all, :order=>"photos.id DESC")
    render :partial => 'image', :collection => @images
  end
  
  private
  def set_swf_file_post_name
    @swf_file_post_name = 'image'
  end
  
end
