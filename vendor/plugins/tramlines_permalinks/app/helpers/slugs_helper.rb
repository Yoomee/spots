module SlugsHelper

  def current_slug?(slug_name)
    return true if @page && @page.is_a?(Page) && @page.slug_is?(slug_name)
    current_section && current_section.slug_is?(slug_name)
  end
  
  def li_with_active_slug(*args, &block)
    slug = args.shift.to_s
    permalink = Permalink.find_by_slug(slug)
    case
      when permalink.nil?
        args.insert(0, false)
      when permalink.model_type == 'Section'
        args.insert(0, current_section?(permalink.model_id) || current_root_section?(permalink.model_id))
      else
        args.insert(0, viewing_page?(permalink.name))
    end
    if block_given?
      content_tag_with_active(:li, *args, &block)
    else
      options = args.extract_options!
      active = args[0]
      html = case
      when args[1]
        args[1]
      when permalink
        link_to_self(permalink.model)
      else
        link_to(slug.titleize, '#')
      end
      content_tag_with_active(:li, active, html, options)
    end
  end
  
  def link_to_slug(*args, &block)
    if block_given?
      link_to(slug_path(args.first), args.second || {}, &block)
    else
      link_to(args.first, slug_path(args.second), args.third || {})
    end
  end
  
  def render_slug(slug, locals = {})
    return "" if !slug_view_exists?(slug)
    render("slugs/#{slug}", locals)
  end
  
  def slug_view_exists?(slug)
    partial_exists?("slugs/#{slug}")
  end
  
  def slug_path(slug)
    slug = slug.to_s
    if permalink = Permalink.find_by_slug(slug)
      "/#{permalink.name}"
    else
      "#"
    end
  end
    
end
