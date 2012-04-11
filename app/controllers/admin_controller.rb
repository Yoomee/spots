class AdminController < ApplicationController
  
  admin_only :index
  
  def index
    @admin_tabs = AdminTab::all
    @selected_tab = AdminTab.find(params[:tab_name]) || @admin_tabs.first
  end
  
end