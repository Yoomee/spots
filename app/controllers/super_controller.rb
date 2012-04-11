class SuperController < ApplicationController
  
  yoomee_only :index
  
  def index
    @ip_members = Member.with_ip_address.paginate(:order => "forename", :page => params[:page], :per_page => 20)
  end
end
