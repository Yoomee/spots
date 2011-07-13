class OrganisationsController < ApplicationController
  
  admin_only :create, :new, :edit, :destroy, :update
  
  before_filter :get_organisation, :only => %w{edit destroy show update}
  
  def index
    @organisations = Organisation.all
  end
  
  def show
  end
  
  def new
    @organisation = Organisation.new
  end
  
  def create
    @organisation = Organisation.new(params[:organisation])
    if @organisation.save
      flash[:notice] = "Successfully created organisation."
      redirect_to @organisation
    else
      render :action => 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @organisation.update_attributes(params[:organisation])
      flash[:notice] = "Successfully updated organisation."
      redirect_to @organisation
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @organisation.destroy
    flash[:notice] = "Successfully deleted organisation."
    redirect_to_waypoint_after_destroy
  end
  
  private
  def get_organisation
    @organisation = Organisation.find(params[:id])
  end
  
end
