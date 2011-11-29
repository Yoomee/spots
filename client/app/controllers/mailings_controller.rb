MailingsController.class_eval do
  
  def update
    @mailing = Mailing.find(params[:id])
    if @mailing.update_attributes(params[:mailing])
      flash[:notice] = "Successfully saved email template."
      redirect_to admin_path
    else
      render :action => 'edit'
    end
  end
  
end