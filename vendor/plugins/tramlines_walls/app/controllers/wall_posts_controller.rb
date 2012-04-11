class WallPostsController < ApplicationController

  # To fix error 'A copy of ApplicationController has been removed from the module tree but is still active!'
#  unloadable

  member_only :create, :create_from_wall_to_wall
  owner_only :destroy, :update
  
  def create
    @wall_post = WallPost.new(params[:wall_post].merge(:member => @logged_in_member))
    @wall_post.text = '' if @wall_post.text == HELP_MESSAGE
    render :update do |page|
      if @wall_post.save
        position = Module::value_to_boolean(params[:reverse]) ? :bottom : :top
        page["#wall_#{@wall_post.wall.id}_body .nothing_yet"].remove
        page.insert_html position, "#wall_#{@wall_post.wall.id}_body .wall_post_list", render('walls/post', :post => @wall_post, :rating_stars => params[:rating_stars])
        page.visual_effect :highlight, "wall_post_#{@wall_post.id}"
        @wall_post = @wall_post.wall.wall_posts.build
      end
      page << refresh_fb_dom if site_uses_fb_connect?
      page << refresh_wall_form(@wall_post, :rating_stars => Module::value_to_boolean(params[:rating_stars]))
    end
  end
  
  def destroy
    @wall_post = WallPost.find params[:id]
    @wall = @wall_post.wall
    @wall_post.destroy
    render :update do |page|
      # page["wall_post_#{@wall_post.id}"].remove
      page << "$('#wall_post_#{@wall_post.id}').fadeOut('fast', function() {$(this).remove();});"
      # page.replace_html 'wall_body', :partial => 'walls/wall_body', :locals => {:wall => @wall, :wall_posts => @wall.wall_posts, :limit => params[:limit]}
    end    
  end

  def edit
    @wall_post = WallPost.find(params[:id])
    render :partial => "edit", :locals => {:wall_post => @wall_post}, :layout => false
  end
  
  def older
    wall = Wall.find(params[:wall_id])
    @wall_posts = wall.older_posts(params.dup)
    position = Module::value_to_boolean(params[:reverse]) ? :top : :bottom
    render :update do |page|
      html = @wall_posts.inject("") {|out, wall_post| render('walls/post', :post => wall_post) << out}
      identifier = "#wall_#{wall.id}_body .wall_post_list"
      params[:page].to_i > 1 ? page.insert_html(position, identifier, html) : page[identifier].replace_html(html)
      if WillPaginate::ViewHelpers.total_pages_for_collection(@wall_posts) > params[:page].to_i
        page << refresh_older_posts_link(wall)
      else
        page["#wall_#{wall.id}_older_wall_posts"].remove
      end
    end    
  end
  
  def update
    @wall_post = WallPost.find params[:id]
    if params[:value].blank?
      render :text => @wall_post.text
    else
      @wall_post.text = params[:value]
      @wall_post.save
      render :text => params[:value]
    end
  end
  
end
WallPostsController::HELP_MESSAGE = 'Post something here'