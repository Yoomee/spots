class WireframesController < ApplicationController
  
  admin_only :show, :index
  
  def show
    render :template => "wireframes/#{params[:id]}", :layout => !(params[:layout] == "false")
  end
  
  def index
    wireframes = Dir.new(RAILS_ROOT + "/client/app/views/wireframes").entries.select{|f| f.match(/html/)}.map{|f| f.split('.')[0..1]} 
     render :inline => "
        <h1>Wireframes</h1>
        <ul>
        <%wireframes.each do |wireframe, layout|%>
          <li>
            <%=link_to(wireframe.titleize, (wireframe_path(wireframe) + (layout == 'nl' ? '?layout=false' : '')), :target => '_blank')%>
          </li>
        <%end%>
      </ul>",
      :locals => { :wireframes => wireframes }
     
  end
  
end