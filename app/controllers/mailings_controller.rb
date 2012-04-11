class MailingsController < ApplicationController

  admin_only :create, :destroy, :edit, :index, :new, :send_emails, :show, :update

  def create
    @mailing = Mailing.new(params[:mailing])
    if @mailing.save
      if @mailing.send_emails_after_save?
        session[:mailing_worker_uid] = @mailing.worker_uid
        flash[:notice] = "Sending #{@template.pluralize(@mailing.mails.count, 'email')}..."
        return redirect_to_waypoint
      else
        flash[:notice] = "Successfully created mailing."
        return redirect_to(@mailing)
      end
    end
    render :action => 'new'
  end

  def destroy
    @mailing = Mailing.find(params[:id])
    @mailing.destroy
    flash[:notice] = "Successfully deleted mailing."
    redirect_to mailings_url
  end
  
  def edit
    @mailing = Mailing.find(params[:id])
  end
  
  def index
    mailings = Mailing.find(:all, :order => "created_at DESC")
    @sent_mailings = mailings.select(&:sent?)
    @unsent_mailings = mailings - @sent_mailings
  end
  
  def new
    @mailing = Mailing.new
  end

  def send_emails
    @mailing = Mailing.find(params[:id])
    if @mailing.send_emails!
      session[:mailing_worker_uid] = @mailing.worker_uid
      flash[:notice] = "Sending #{@template.pluralize(@mailing.mails.count, 'email')}..."
    else
      flash[:error] = "There was a problem sending the emails"
    end
    redirect_to :action => 'index'
  end
  
  def show
    @mailing = Mailing.find(params[:id])
  end
  
  def update
    @mailing = Mailing.find(params[:id])
    if @mailing.update_attributes(params[:mailing])
      if @mailing.send_emails_after_save?
        session[:mailing_worker_uid] = @mailing.worker_uid
        flash[:notice] = "Sending #{@template.pluralize(@mailing.mails.count, 'email')}..."
        return redirect_to_waypoint
      else
        flash[:notice] = "Successfully updated mailing."
        redirect_to @mailing
      end
    else
      render :action => 'edit'
    end
  end
  
  def update_progress
    render :update do |page|
      page["#mailing_progress"].replace(render_mailing_progress(params[:status]))
    end
  end
  
end
