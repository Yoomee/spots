class MediaLibraryController < ApplicationController
  
  def show
    unless params[:tab].blank?
      @open_tab = params[:tab]
    end
    @member = Member.find params[:member_id]
  end
  
end