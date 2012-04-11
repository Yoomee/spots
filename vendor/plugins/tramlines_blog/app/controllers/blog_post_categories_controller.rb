class BlogPostCategoriesController < ApplicationController
  
  admin_only :create, :destroy, :edit, :index, :new, :update
  
  admin_link 'Blog', :new, 'New category'
  admin_link 'Blog', :index, 'List categories'
  
  def index
    @blog_categories = BlogPostCategory.all
  end
  
  def show
    @blog_post_category = BlogPostCategory.find(params[:id])
  end
  
  def new
    @blog_post_category = BlogPostCategory.new
  end
  
  def create
    @blog_post_category = BlogPostCategory.new(params[:blog_post_category])
    if @blog_post_category.save
      flash[:notice] = "Successfully created blog category."
      redirect_to blog_post_categories_path
    else
      render :action => 'new'
    end
  end
  
  def edit
    @blog_post_category = BlogPostCategory.find(params[:id])
  end
  
  def update
    @blog_post_category = BlogPostCategory.find(params[:id])
    if @blog_post_category.update_attributes(params[:blog_post_category])
      flash[:notice] = "Successfully updated blog category."
      redirect_to @blog_post_category
    else
      render :action => 'edit'
    end
  end
  
  def destroy
    @blog_post_category = BlogPostCategory.find(params[:id])
    @blog_post_category.destroy
    flash[:notice] = "Successfully destroyed blog category."
    redirect_to blog_post_categories_url
  end
end
