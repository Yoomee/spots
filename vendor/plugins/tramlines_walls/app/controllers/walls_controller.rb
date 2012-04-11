# this is not used anymore but is left here incase older client projects reference it
class WallsController < ApplicationController

  def older_posts
    wall = Wall.find(params[:id])
    @wall_posts = wall.older_posts(params.dup)
    position = Module::value_to_boolean(params[:reverse]) ? :top : :bottom
    render :update do |page|
      identifier = "#wall_#{wall.id}_body .wall_post_list"
      if params[:page].to_i > 1
        @wall_posts.each {|wall_post| page.insert_html position, identifier, render('walls/post', :post => wall_post)}
      else
        @wall_posts.each {|wall_post| page[identifier].replace_html render('walls/post', :post => wall_post)}
      end
      if WillPaginate::ViewHelpers.total_pages_for_collection(@wall_posts) > params[:page].to_i
        page << refresh_older_posts_link(wall)
      else
        page["#wall_#{wall.id}_older_wall_posts"].remove
      end
    end    
  end
  
end
