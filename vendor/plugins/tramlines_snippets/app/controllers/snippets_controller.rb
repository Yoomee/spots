class SnippetsController < ApplicationController
  
  admin_only :edit, :index, :update
  yoomee_only :destroy
  
  def destroy
    @snippet = Snippet.find(params[:id])
    if @snippet.destroy
      flash[:notice] = "Successfully deleted #{@snippet.human_name} snippet."
    else
      flash[:error] = "Could not delete #{@snippet.human_name} snippet."
    end
    redirect_to(snippets_path)
  end
  
  def edit
    @snippet = Snippet.find(params[:id])
  end

  def index
    @snippets = Snippet.site_snippets
  end
  
  def update
    @snippet = Snippet.find(params[:id])
    if @snippet.update_attributes(params[:snippet])
      request.xhr? ? render(:text => @snippet.text) : redirect_to_waypoint
    else
      render :action => 'edit'
    end
  end
  
end