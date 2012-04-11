class PagesController < ApplicationController

  admin_only :create, :destroy, :edit, :new, :update

  admin_link 'Content', :new, 'New page'

  before_filter :get_page, :only => %w{destroy edit show update}  

  class << self
    
    def allowed_to_with_publish_checking?(url_options, member)
      if url_options[:action].to_sym == :show && url_options[:id] && Page.exists?(url_options[:id])
        page = Page.find(url_options[:id])
        allowed_to_without_publish_checking?(url_options, member) && (page.published? || member.try(:is_admin?))
      elsif url_options[:action].to_sym == :destroy && url_options[:id] && Page.exists?(url_options[:id])
        page = Page.find(url_options[:id])
        return allowed_to_without_publish_checking?(url_options, member) if page.slug.blank?
        member && member.yoomee_staff?
      else
        allowed_to_without_publish_checking?(url_options, member)
      end
    end
    alias_method_chain :allowed_to?, :publish_checking
    
  end

  def create
    @page = Page.new params[:page]
    if @page.save
      flash[:notice] = "#{@page.type_name.titleize} successfully created"
      redirect_to @page
    else
      render :action => 'new'
    end
  end

  def destroy
    flash[:notice] = "#{@page.type_name.titleize} deleted" if @page.destroy
    redirect_to section_path(@page.section)
  end
  
  def edit
  end
  
  def new
    page_attrs = (params[:page] || {}).merge(:section_id => params[:section_id])
    @page = Page.new(page_attrs)
  end

  def show

  end
  
  def update
    if @page.update_attributes params[:page]
      flash[:notice] = "#{@page.type_name.titleize} updated successfully"
      redirect_to @page
    else
      render :action => 'edit'
    end
  end
  
  private
  def get_page
    @page = Page.find params[:id]
  end
  
end