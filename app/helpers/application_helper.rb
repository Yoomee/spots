# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def included_javascript_tags
    @included_javascript_tags ||= []
  end
  
  def included_stylesheet_tags
    @included_stylesheet_tags ||= []
  end

  def javascript_include_tag_once(*sources)
    out = ""
    sources.each do |source|
      if !included_javascript_tags.include?(source)
        out << javascript_include_tag(source)
        included_javascript_tags << source
      end
    end
    content_for(:head) {out}
  end
  
  def stylesheet_link_tag_once(*sources)
    out = ""
    sources.each do |source|
      if !included_stylesheet_tags.include?(source)
        out << stylesheet_link_tag(source)
        included_stylesheet_tags << source
      end
    end
    content_for(:head) {out}
  end
  
  def render_breadcrumb(breadcrumb, separator = '&nbsp;&gt;&nbsp;')
    # The breadcrumb could be rendered twice, so we should avoid modifying it
    breadcrumb_arr = (breadcrumb || []).dup
    breadcrumb_arr.unshift ["Home",  {:controller => 'home', :action => 'welcome'} ]
    breadcrumb_string = breadcrumb_arr.map do |item|
      if item.size == 2
        if item[1].is_a? Hash
          if !item[1][:action]
            item[1][:action] = 'index'
          end
          link_to item[0], item[1]
        else
          link_to item[0], item[1]
        end
      else
        item[0]
      end
    end
    breadcrumb_string.join separator
  end
  
  def render_star
    "<span class='required'>*</span>"
  end
  
  # Moved to application_controller_concerns/helper_methods
  # def view_exists?(view_name)
  #   ApplicationController.view_paths.any? do |path|
  #     File.exists?("#{path}/#{view_name}.html.haml")
  #   end
  # end
  # 
  # def partial_exists?(view_name)
  #   view_name = view_name.reverse.sub!(/_?\//, "_/").reverse
  #   ApplicationController.view_paths.any? do |path|
  #     File.exists?("#{path}/#{view_name}.html.haml")
  #   end
  # end

end
