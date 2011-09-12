DocumentsController.class_eval do

  admin_only :create, :index, :new

  def create
    @document = Document.new(params[:document])
    if @document.save
      flash[:notice] = "Successfully created document."
      redirect_to (@document.activity || documents_url)
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @document.destroy
    flash[:notice] = "Successfully deleted document."
    redirect_to (@document.activity || documents_url)
  end
  
  def new_with_activities
    new_without_activities
    @document.activity_id = params[:activity_id]
  end
  alias_method_chain :new, :activities

  def update
    if @document.update_attributes(params[:document])
      flash[:notice] = "Successfully updated document."
      redirect_to (@document.activity || documents_url)
    else
      render :action => 'edit'
    end
  end
  
end
