module LinksHelper

  def link_if_exists(options = {})
    klass = options[:type].constantize
    if klass.exists?(:id => options[:id])
      link_to(options[:text], send("#{options[:type].underscore}_path", options[:id]), options[:html])
    else
      options[:text]
    end
  end
  
  def link_to_self(*args, &block)
    link_to(*args.insert(0, *args.first), &block)
  end
  
  def link_to_url(url, *args, &block)
    options = args.extract_options!.symbolize_keys.reverse_merge!(:http => true, :target => "_blank")
    link_url = prepend_http(url)
    url = url.sub(/^https?:\/\//, '') if !options[:http]
    link_to(url, link_url, options, &block)
  end
  
  def link_to_wireframe(name, wireframe)
    link_to(name, wireframe_path(wireframe))
  end
  
  def link_with_active_if_current(*args, &block)
    if block_given?
      url = args.first
      html_options = args.second || {}
      html_options[:class] = "active #{html_options[:class]}".strip if current_page?(url)
      link_to(args.first, html_options, &block)
    else
      url = args.second
      html_options = args.third || {}
      html_options[:class] = "active #{html_options[:class]}".strip if current_page?(url)
      link_to(args.first, args.second, html_options)
    end
  end
  
  def prepend_http(url)
    url.match(/^.*:\/\//) ? url : "http://" + url
  end

  def with_count(str, count, options = {})
    return str if count.zero?
    options.reverse_merge!(:bracket => true)
    if options[:bracket]
      "#{str} (#{count})"
    else
      "#{str} #{count}"
    end
  end
  
end
