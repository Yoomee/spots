class DocumentFoldersController < ApplicationController
  
  owner_only :edit, :update, :destroy
  member_only :new, :create, :show
  
  before_filter :get_documents_without_folder, :only => "index"
  
  def index
    @document_folders = DocumentFolder.all
  end
  
  def new
    @document_folder = DocumentFolder.new
  end
  
  def create
    @document_folder = DocumentFolder.new(params[:document_folder])
    if @document_folder.save
      flash[:notice] = "Successfully created folder."
      redirect_to document_folders_url
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @document_folder = DocumentFolder.find(params[:id])
    @document_folder.destroy
    flash[:notice] = "Successfully deleted folder."
    redirect_to document_folders_url
  end
  
  def edit
    @document_folder = DocumentFolder.find(params[:id])
  end
  
  def update
    @document_folder = DocumentFolder.find(params[:id])
    if @document_folder.update_attributes(params[:document_folder])
      flash[:notice] = "Successfully updated folder."
      redirect_to document_folders_url
    else
      render :action => 'edit'
    end
  end
  
  def show
    @document_folder = DocumentFolder.find(params[:id])
  end
  
  protected
  def begin_of_association_chain
   admin_logged_in? ? nil : @logged_in_member
  end
  
  private
  def get_documents_without_folder
    @documents_without_folder = admin_logged_in? ? Document.without_folder : @logged_in_member.documents.without_folder
  end
  
end
