module BreadcrumbHelper


  def breadcrumb(object)
    if object.is_a?(Array)
      @breadcrumb = [['Home', home_path]] + object
    else
      @breadcrumb = object.respond_to?(:breadcrumb) ? [['Home', home_path]] + object.breadcrumb : nil
    end
  end
  
  def render_breadcrumb(options = {})
    @breadcrumb ||= breadcrumb(options[:object])
    separator = options[:separator] || ''
    if @breadcrumb
      html = ''
      links = @breadcrumb.map do |item|
        bc_class = "breadcrumb"
        bc_class += ' start' if item == @breadcrumb.first
        if item == @breadcrumb.last
          bc_class += ' end'
          name = item.is_a?(Array) ? item[0] : item
          content_tag(:span, name, :class => "last_crumb")
        else
          name, link = item.is_a?(Array) ? item : [item, item]
          link_to(name, link, :class => bc_class)
        end
      end
      html << links.join(separator)
      out = content_tag(:div, html, :id => 'breadcrumb')
    end
    @breadcrumb = nil
    out
  end
  
  # def breadcrumb(breadcrumb)
  #   @breadcrumb = breadcrumb
  # end
  # 
  # def render_breadcrumb
  #   breadcrumb_items.join("&nbsp;&gt;&nbsp;")
  # end
  # 
  # private
  # def breadcrumb_items
  #   @breadcrumb ||= []
  #   @breadcrumb = [[@breadcrumb]] if @breadcrumb.is_a?(String)
  #   @breadcrumb.unshift(['Home', :home])
  #   @breadcrumb.map do |item|
  #     case item
  #       when Array
  #         item[1].nil?  ? item[0] : link_to(item[0], item[1])
  #       when String
  #         item
  #       else
  #         link_to(item, item)
  #     end
  #   end
  # end

end
