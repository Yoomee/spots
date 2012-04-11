class BlogsController < ApplicationController
  
  admin_only :create, :destroy, :edit, :new, :update
  
  admin_link 'Blog', :new
  admin_link 'Blog', :index
  
  before_filter :get_blog, :only => [:destroy, :edit, :update]

  POSTS_PER_PAGE = 10
  
  def create
    @blog = Blog.new(params[:blog])
    if @blog.save
      flash[:notice] = "Successfully created blog."
      redirect_to @blog
    else
      render :action => 'new'
    end
  end
  
  def destroy
    @blog.destroy
    flash[:notice] = "Successfully destroyed blog."
    redirect_to blogs_url
  end
  
  def edit
  end
  
  def index
    @blogs = Blog.all
  end
  
  def new
    @blog = Blog.new(:member => @logged_in_member)
  end
  
  def show
    @blog = Blog.find_by_id(params[:id]) || Blog.first
    return redirect_to(:action => "index") if @blog.nil?
    respond_to do |format|
      format.html do
        @blog_posts = @blog.blog_posts.paginate(:order => "created_at DESC", :page => params[:page], :per_page => POSTS_PER_PAGE)
        render
      end
      format.rss do
        @blog_posts = @blog.blog_posts
        @description = APP_CONFIG[:site_slogan] || ""
        @language = "EN"
        @link = @template.site_url
        @title = "#{APP_CONFIG[:site_name]} - #{@blog.name}"
        render 'rss'
      end
    end
  end
  
  def update
    if @blog.update_attributes(params[:blog])
      flash[:notice] = "Successfully updated blog."
      redirect_to @blog
    else
      render :action => 'edit'
    end
  end

  private
  def get_blog
    @blog = Blog.find(params[:id])
  end

end
