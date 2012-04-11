class SectionsController < ApplicationController

  admin_only :create, :destroy, :edit, :new, :update, :order, :update_weights

  admin_link 'Content', :new, 'New section'
  admin_link 'Content', :index, 'List sections'

  before_filter :get_section, :only => %w{archive destroy edit show update}

  class << self
    
    def allowed_to_with_slugs?(url_options, member)
      if url_options[:action].to_sym == :destroy && url_options[:id] && Section.exists?(url_options[:id])
        section = Section.find(url_options[:id])
        return allowed_to_without_slugs?(url_options, member) if section.slug.blank?
        member && member.yoomee_staff?
      else
        allowed_to_without_slugs?(url_options, member)
      end
    end
    alias_method_chain :allowed_to?, :slugs
    
  end

  def archive
    begin
      @section = Section.find params[:id]
      @month = params[:month].to_i
      @year = params[:year].to_i
      if @month.zero? || @year.zero?
        month_and_year = @section.last_month_and_year
        @month = month_and_year[0]
        @year = month_and_year[1]
      end
      @page_title = "#{@section.name}: #{Date::MONTHNAMES[@month]} #{@year}"
      @pages = @section.pages.published.for_month_and_year(@month, @year)
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end

  def create
    @section = Section.new(params[:section])
    if @section.save
      flash[:notice] = 'Your section has been created'
      redirect_to_waypoint
    else
      render :action => 'new'
    end
  end
  
  def destroy
    flash[:notice] = 'Section deleted' if @section.destroy
    redirect_to sections_path
  end
  
  def edit
  end
  
  def index
    @sections = logged_in_member_is_admin? ? Section.root : Section.root.not_hidden.not_draft
    respond_to do |format|
      format.html
      format.xml # index.xml.builder
    end
  end
  
  def new
    @section = Section.new(:parent_id => params[:section_id])
  end
  
  def order
    if @section = Section.find_by_id(params[:id])
      @pages_sections = @section.all_children(:show_expired => true, :show_hidden => true, :latest => true)
      # @pages_sections = @section.pages + @section.children
      # @pages_sections.extend(SortByWeightAndLatest)
      # @pages_sections = @pages_sections.sort_by_weight_and_latest
    else
      @pages_sections = Section.root
    end
  end
  
  def rss
    begin
      @section = Section.find params[:id]
      @description = APP_CONFIG[:site_slogan] || ""
      @language = "EN"
      @link = APP_CONFIG[:site_url]
      @title = "#{APP_CONFIG[:site_name]} - #{@section.name}"
      render :layout => false
    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
  
  def show
    case @section.view
      when 'latest_stories'
        @pages_sections = @section.pages.published.latest + @section.children
        @pages_sections.extend(SortByWeightAndLatest)
        @pages_sections = @pages_sections.sort_by_weight_and_latest.paginate(:page => params[:page], :per_page => (APP_CONFIG[:latest_stories_items_per_page] || 6))
        render :action => 'latest_stories'
      when 'first_page'
        redirect_to send("#{@section.destination_type}_path", @section.destination) unless @section.destination == @section
    end
    # Otherwise use show view
    @pages = @section.pages.published.weighted.paginate(:page => params[:page], :per_page => (APP_CONFIG[:section_pages_items_per_page] || 10))
    @pages_sections = @pages + @section.children
    @pages_sections = @pages_sections.sort_by(&:weight)
    @pages_sections = @pages_sections.paginate(:page => params[:page], :per_page => (APP_CONFIG[:section_pages_items_per_page] || 10))
  end
  
  def update
    if @section.update_attributes(params[:section])
      flash[:notice] = 'Section updated successfully'
      redirect_to_waypoint
    else
      render :action => 'edit'
    end
  end
  
  def update_weights
    params[:pages_sections].each do |index, sortable_hash|
      sortable_hash["sortable_type"].constantize.find(sortable_hash["sortable_id"]).update_attribute(:weight, index)
    end
    redirect_to sections_path
  end

  module SortByWeightAndLatest

    def compare_weight_and_latest(item_a, item_b)
      weight_comp = item_a.weight <=> item_b.weight
      return weight_comp unless weight_comp.zero?
      item_a_date = get_date(item_a)
      item_b_date = get_date(item_b)
      item_b_date <=> item_a_date
    end
    
    def get_date(item)
      item.is_a?(Section) ?  item.created_at : item.publish_on
    end      

    def sort_by_weight_and_latest
      sort do |item_a, item_b|
        compare_weight_and_latest(item_a, item_b)
      end
    end

  end  
  
  private
  def get_section
    @section = Section.find params[:id]
  end
end

