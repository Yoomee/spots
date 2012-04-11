# mainly used (and overwritten) in tramlines_shouts
class TagsController < ApplicationController
  
  before_filter :get_tag, :only => %{show}
  
  def autocomplete
    search_term = params[:term].downcase.gsub('_', ' ').gsub(/[^A-Za-z\d\-\s]/, '').strip
    term_list = [*search_term.gsub('-', ' ').split]
    if term_list.size < 2
      tags = Tag.named_like(term_list.join(" ")).limit(5)
    else
      tags = Tag.named_like(search_term)
      if tags.size < 5
        term_list.each do |term|
          tags += Tag.named_like(term).limit(5 - tags.size) if term.length >= 3
          break if tags.size >= 5
        end
      end
    end
    tags_list = tags.uniq.collect {|t| {:name => t.name.downcase, :value => t.name.downcase}}
    if term_list.size > 2
      tags_list << {:name => "<em>Please use fewer words.</em>", :value => ""}
    elsif search_term.length > 25
      tags_list << {:name => "<em>Please use less than 25 characters.</em>", :value => ""}
    else
      tags_list << {:name => "<em>Click here to add the new tag:</em> #{search_term}", :value => search_term} unless tags_list.collect(&:values).flatten.include?(search_term)
    end
    render :json => tags_list
  end
  
  def show
    
  end
  
  private
  def get_tag
    @tag = Tag.find_by_name(CGI::unescape(params[:id]))
  end
  
end