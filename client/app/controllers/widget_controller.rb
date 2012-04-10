class WidgetController < ApplicationController

  def index
    @organisation_group = OrganisationGroup.find(params[:id])
    render :template => 'widget/index', :layout => false, :content_type => 'application/javascript'
  end

end
