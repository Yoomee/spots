module LayoutHelper
  
  def body_tag(options = {}, &block)
    options[:id] ||= id_for_body_tag
    body_class = "#{classes_for_body_tag_string} #{options[:class]}".strip
    options[:class] = body_class unless body_class.blank?
    concat content_tag(:body, capture(&block), options)
  end

  def classes_for_body_tag_string
    classes_for_body_tag.join(' ')
  end
  
  #e.g. :class => class_list("always_class", "maybe_class1" => true_or_false?)
  def class_list(*args)
    class_hash = args.extract_options!
    class_hash.each do |class_name, condition|
      args << class_name.to_s if condition
    end
    args.empty? ? nil : args.join(' ')
  end
  
  def content_for_layout
    if @no_content_row
      @content_for_layout
    else
      content_tag(:div, content_tag(:div, @content_for_layout, :class => "twelvecol"), :class => "row")
    end
  end
  
  def content_tag_with_active(*args, &block)
    options = args.extract_options!.symbolize_keys
    options ||= {}
    options[:class] = (options[:class].blank? ? "active" : options[:class] + " active") if args.second
    if block_given?
      content_tag(args.first, options, &block)
    else
      content_tag(args.first, args.third, options)
    end
  end

  def dl_item_if_not_blank(title, description)
    return "" if description.blank?
    out = content_tag(:dt, title)
    out + content_tag(:dd, description)
  end
  
  def li_with_active(*args, &block)
    content_tag_with_active(:li, *args, &block)
  end
  
  def no_content_row
    @no_content_row = true
  end
  
  def rounded_corner_container(*args, &block)
    options = args.extract_options!
    options[:class] = "#{options[:class]} corner_container".strip
    corners = 4.times.inject("") {|out, i| out + "<div class='corner c#{i+1}'></div>"}
    if block_given?
      concat(content_tag(:div, corners + capture(&block) , options))
    else
      content_tag(:div, corners + args.first, options)
    end
  end
  
  private
  def id_for_body_tag
    is_home? ? 'home' : 'inside'
  end
  
  def classes_for_body_tag
    returning classes = [] do
      classes << case
        when @section && @section.is_a?(Section) && @section.id
          out = "section_#{@section.id}"
          @section.slug.blank? ? out : out + " section_#{@section.slug.downcase.fully_underscore}"
        when @page && @page.is_a?(Page)          
          out = "page_#{@page.id} section_#{@page.section_id}"
          out << " page_#{@page.slug.downcase.fully_underscore}" if !@page.slug.blank?
          @page.section_slug.blank? ? out : out + " section_#{@page.section_slug.downcase.fully_underscore}"
      end
      classes << "controller_#{controller_name}"
      classes << "action_#{action_name}"
      classes << (logged_in_member ? 'logged_in' : 'logged_out')
    end
  end

end