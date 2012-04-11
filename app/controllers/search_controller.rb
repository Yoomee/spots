class SearchController < ApplicationController

  protect_from_forgery :except => :create

  def create
    options = {:match_mode => params[:match_mode], :autocomplete => params[:autocomplete]}
    @search = Search.new params[:search], options
    if request.xhr?
      partial_view_path = params[:results_view_path] ? "#{params[:results_view_path]}/" : ""
      return render(:partial => "#{partial_view_path}ajax_search_results", :locals => {:search => @search})
    end
  end

  #used in ckeditor link dialog
  def jquery_autocomplete
    search = Search.new({:term => params.delete(:q)}, :autocomplete => true)
    logger.info "results = #{search.results.inspect}"
    results = search.results.map {|result| {:name => "#{result.to_s} (#{result.class})", :url => polymorphic_path(result)}}
    results += search.non_sphinx_results.map {|result| {:name => "#{result.form_title} (Enquiry form)", :url => url_for(:controller => 'enquiries', :action => 'new', :id => result.form_name)}}
    logger.info "results size = #{search.results.size}"    
    render :json => results.to_json
  end

  # used with formtastic input options :autocomplete and :fb_autocomplete
  def formtastic_autocomplete
    search = Search.new({:term => params[:term], :models => params[:models]}, :with => params[:with], :autocomplete => true)
    search_results = search.results
    results = search_results.map {|result| {:value => result.to_s, :id => result.id}}
    render :json => results.to_json
  end

end