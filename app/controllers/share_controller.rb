class ShareController < ApplicationController
  
  def create
    model_name = params[:model_name] 
    @model = model_name.camelize.constantize.find(params[:id])
    if logged_in_member
      params[:share][:email] = logged_in_member.email
      params[:share][:name] = logged_in_member.full_name
    end
    @share = Share.new(params[:share])
    if @share.save
      Notifier.deliver_share_link @model, params[:share]
      flash[:notice] = "Thanks for sharing this #{model_name.to_s}"
      redirect_to :action => "new", :model_name => model_name, :id => params[:id]
    else
      puts @share.errors.full_messages
      flash[:notice] = "There was an error sharing this #{model_name.to_s}. Please ensure you entered the requred details."
      render :action => "new"
    end
  end
  
  def new
    @share = Share.new
    @model = params[:model_name].camelize.constantize.find(params[:id])
    render :layout => false if request.xhr?
  end
  
  def options
    @model = params[:model_name].camelize.constantize.find(params[:id])
    
    @short_url = ShortUrl::shorten(polymorphic_url(@model))
    render :layout => false
  end
  
end