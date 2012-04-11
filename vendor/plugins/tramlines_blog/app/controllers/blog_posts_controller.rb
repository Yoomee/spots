class BlogPostsController < ApplicationController
  
  admin_only :create, :destroy, :edit, :new, :update
  
  admin_link 'Blog', :new
  
  before_filter :get_blog_post, :only => [:destroy, :edit, :show, :update]
  before_filter :get_blog_post_category, :only => [:show]
  
  def create
    @blog_post = BlogPost.new(params[:blog_post])
    if @blog_post.save
      flash[:notice] = "Successfully created blog post."
      redirect_to @blog_post
    else
      render :action => 'new'
    end
  end

  def destroy
    @blog_post.destroy
    flash[:notice] = "Successfully destroyed blog post."
    redirect_to @blog_post.blog
  end
  
  def edit
  end
  
  def index
    if params[:blog_id]
      @blog = Blog.find(params[:blog_id])
      @blog_posts = @blog.posts.paginate(:per_page => "10", :page => params[:page])
    else
      @blog_posts = BlogPost.all
    end
  end
  
  def new
    @blog_post = BlogPost.new(:member => @logged_in_member, :blog_id => params[:blog_id])
  end
  
  def show
  end
  
  def update
    if @blog_post.update_attributes(params[:blog_post])
      flash[:notice] = "Successfully updated blog post."
      redirect_to @blog_post
    else
      render :action => 'edit'
    end
  end

  private
  def get_blog_post
    @blog_post = BlogPost.find(params[:id])
  end

  def get_blog_post_category
    @blog_post_category = BlogPostCategory.find_by_id(params[:blog_post_category_id])
  end

end
