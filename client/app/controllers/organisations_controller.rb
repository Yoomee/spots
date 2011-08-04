class OrganisationsController < ApplicationController
  
  admin_only :new
  owner_only :edit, :destroy, :update
  
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
      if logged_in?
        flash[:notice] = "Successfully created organisation."
        redirect_to @organisation
      else
        flash[:notice] = "Thanks for signing up! Now enter some activites, you can do this later if you want."
        session[:logged_in_member_id] = @organisation.member_id
        redirect_to organisation_time_slots_path(@organisation, :signup => true)
      end
    else
      render :action => logged_in? ? 'new' : 'signup'
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

  def search_address
    if params[:lat] && params[:lng]
      lat, lng = params[:lat], params[:lng]
    else
      lat, lng = GoogleGeocode::get_lat_lng(params[:address])
    end
    if lat && lng
      @activity = Activity.find(params[:activity_id])
      if @organisation = Organisation.with_activity(@activity).nearest_to(Location.new(:lat => lat, :lng => lng)).first
        html = @template.render("activities/organisation_panel", :activity => @activity, :organisation => @organisation, :lat => lat, :lng => lng)
        return render(:json => {:lat => @organisation.lat, :lng => @organisation.lng, :organisation_html => html})
      end
    end
    render :text => "not found"
  end

  def signup
    if logged_in?
      render_404
    else
      @organisation = Organisation.new
      @organisation.build_member
    end
  end
  
  private
  def get_organisation
    @organisation = Organisation.find(params[:id])
  end
  
end
