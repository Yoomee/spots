module OptionsPanelHelper
  
  def self.included(klass)
    klass.send(:attr_accessor, :separating_links, :prefixing_separated_links)
  end
    
  def back_link(link_text = 'Back')
    link_to_waypoint link_text
  end
  
  def delete_link(object,options={})
    object_class, object_name = object_class_and_name(object,options)
    options.reverse_merge!(:link_text => "Delete #{object_name}",:method => :delete, :confirm => "Are you sure you want to delete this #{object_name}?")
    link_if_allowed(
      options.delete(:link_text),
      send("#{object_class}_proc",object),
      options
    )
  end  
  
  def edit_link(object,options={})
    object_class, object_name = object_class_and_name(object,options)
    options.reverse_merge!(:link_text => "Edit #{object_name}")
    link_if_allowed(
      options.delete(:link_text),
      send("edit_#{object_class}_proc",object),
      options
    )
  end
  
  def new_link(object,options={})
    object_class, object_name = object_class_and_name(object,options)
    options.reverse_merge!(:link_text => "New #{object_name}")
    link_if_allowed(
      options.delete(:link_text),
      send("new_#{object_class}_proc"),
      options
    )
  end
  
  
  def options_panel(*args,&block)
    options = args.extract_options!
    out = "<br class='clear'/>"
    if object = args[0]
      only = options.delete(:only)
      if object.class.in?([Array, String, Symbol])
        only ||= [:back, :new]
        object = object.first if object.is_a?(Array)
      else
        only ||= [:back, :edit, :delete, :new]
      end
      links = ""
      self.separating_links = true
      links << back_link if only.include?(:back)
      links << edit_link(object,options.dup) if only.include?(:edit) && object.try(:id)
      links << delete_link(object,options.dup) if only.include?(:delete) && object.try(:id)
      links << new_link(object,options.dup) if only.include?(:new)
      self.separating_links = false
      out << content_tag(:div, links, :class => 'options_panel')
    elsif block_given?
      needs_concat = true
      out << content_tag(:div, :class => 'options_panel') {separate_links(&block)}
    else
      out << content_tag(:div, back_link, :class => 'options_panel')
    end
    out = content_tag(:div, content_tag(:div, out, :class => "twelvecol"), :class => "row") if options[:row]
    needs_concat ? concat(out) : out
  end
  
  def separate_links(&block)
    self.separating_links = true
    self.prefixing_separated_links = false
    out = capture(&block).strip
    self.prefixing_separated_links = false
    self.separating_links = false
    concat(out)
  end
  
  private
  def object_class_and_name(object, options={})
    object_class = object.class.in?([String,Symbol]) ? object.to_s.singularize : object.class.to_s.underscore
    object_name = options[:name] || object_class.titleize.downcase
    return object_class, object_name
  end
  
end

module ActionView::Helpers::UrlHelper
  
  unless method_defined?(:link_to_without_link_separation)

    def link_to_function_with_link_separation(name, *args, &block)
      if separating_links
        if prefixing_separated_links
          html_options = args.extract_options!.symbolize_keys
          html_options[:prefix] ||= ' | '
          link_to_function_without_link_separation(name, *args << html_options, &block)
        else
          self.prefixing_separated_links = true
          link_to_function_without_link_separation(name, *args, &block)
        end
      else
        link_to_function_without_link_separation(name, *args, &block)
      end
    end
    alias_method_chain :link_to_function, :link_separation

    def link_to_with_link_separation(*args, &block)
      if separating_links
        if prefixing_separated_links
          if block_given?
            options = args.first || {}
            html_options = args.second || {}
            html_options[:prefix] ||= ' | '
            link_to_without_link_separation(options, html_options, &block)
          else
            name = args.first
            options = args.second || {}
            html_options = args.third || {}
            html_options[:prefix] ||= ' | '
            link_to_without_link_separation(name, options, html_options)
          end
        else
          self.prefixing_separated_links = true
          link_to_without_link_separation(*args, &block)
        end
      else
        link_to_without_link_separation(*args, &block)
      end
    end
    alias_method_chain :link_to, :link_separation
    
  end

end
