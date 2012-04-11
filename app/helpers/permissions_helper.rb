module PermissionsHelper
  
  def allowed_to?(url_item, options = {})
    # Dup options, because we don't want any modifications to be passed to link_to
    options = options.dup
    options.symbolize_keys!
    raise ArgumentError.new("PermissionsHelper#allowed_to? should take a REST helper Proc for its first argument rather than a String, eg. page_proc(page)") if url_item.is_a?(String)
    member = options[:member] || @logged_in_member
    options[:method] ||= :get
    if url_item.is_a?(Hash)
      url_options = url_item.symbolize_keys
      url_options[:action] ||= 'index'
    elsif url_item.is_a?(Proc)
      #url_options = ActionController::Routing::Routes.recognize_path(url, :method => options[:method])
      url_options = url_item.call(:path_hash)
      case options[:method].try(:to_sym)
        when :delete
          url_options[:action] = 'destroy' if url_options[:action]=="show"
        when :post 
          url_options[:action] = 'create' if url_options[:action]=="show"
        when :put
          url_options[:action] = 'update' if url_options[:action]=="show"
      end
    else
      # If model itself has been passed-in
      return allowed_to?(proc_for(url_item), options)
    end
    url_controller = "#{url_options.delete(:controller).camelcase}Controller".constantize
    url_controller.allowed_to?(url_options, member)
  end
  
  def allowed_to_edit?(object)
    return false if object.nil?
    if respond_to?("edit_#{object.class.to_s.underscore}_proc")
      allowed_to?(send("edit_#{object.class.to_s.underscore}_proc", object))
    else
      object.owned_by?(@logged_in_member) || admin_logged_in?
    end
  end  
  
  def get_fancy_options(html_options)
    url = html_options.delete(:url) || {"controller" => @controller.controller_path, "action" => action_name}.merge!(params)
    if anchor = html_options.delete(:anchor)
      url = url.is_a?(String) ? "#{url}##{anchor}" : url.merge(:anchor => anchor)
    end
    html_options[:class] = "fancy link_to_login #{html_options[:class]}"
    html_options[:onclick] = remote_function(:url => set_login_waypoint_path(:url => url))
    if wrapper_class = html_options.delete(:fancybox_wrapper_class)
      html_options[:onclick] = "$('#fancybox-wrap').attr('class', '#{wrapper_class}');" + html_options[:onclick]
    end
    html_options
  end
  
  def link_if_allowed(*args, &block)
    if block_given?
      url_proc = args.first
      ActiveSupport::Deprecation.warn("PermissionsHelper#allowed_to? should take a Proc for its first argument rather than a hash, eg. page_proc(page). This will make Tramlines run much faster!!!", caller) if url_proc.is_a?(Hash)
      html_options = args.second || {}
      show_fancybox = html_options.delete(:fancy)
      if allowed_to?(url_proc, html_options)
        link_to(resolve_path(url_proc), html_options, &block)
      else
        return "" unless show_fancybox
        html_options[:url] = get_url_hash(url_proc) unless html_options.delete(:redirect_to_current)
        link_to_login_fancybox(html_options, &block)
      end
    else
      name = args.first
      url_proc = args.second
      ActiveSupport::Deprecation.warn("PermissionsHelper#allowed_to? should take a Proc for its first argument rather than a hash, eg. page_proc(page). This will make Tramlines run much faster!!!", caller) if url_proc.is_a?(Hash)
      html_options = args.third || {}
      show_fancybox = html_options.delete(:fancy)      
      if allowed_to?(url_proc, html_options)
        link_to(name, resolve_path(url_proc), html_options)
      else
        return "" unless show_fancybox
        html_options[:url] = get_url_hash(url_proc) unless html_options.delete(:redirect_to_current)
        link_to_login_fancybox(name, html_options)
      end
    end
  end
  alias_method :link_to_if_allowed, :link_if_allowed
  
  def link_or_not(*args, &block)
    if block_given?
      url_proc = args.first
      ActiveSupport::Deprecation.warn("PermissionsHelper#allowed_to? should take a Proc for its first argument rather than a hash, eg. page_proc(page). This will make Tramlines run much faster!!!", caller) if url_proc.is_a?(Hash)
      html_options = args.second || {}
      show_fancybox = html_options.delete(:fancy)
      if allowed_to?(url_proc, html_options)
        link_to(resolve_path(url_proc), html_options, &block)
      else
        yield
      end
    else
      name = args.first
      url_proc = args.second
      ActiveSupport::Deprecation.warn("PermissionsHelper#allowed_to? should take a Proc for its first argument rather than a hash, eg. page_proc(page). This will make Tramlines run much faster!!!", caller) if url_proc.is_a?(Hash)
      html_options = args.third || {}
      show_fancybox = html_options.delete(:fancy)      
      if allowed_to?(url_proc, html_options)
        link_to(name, resolve_path(url_proc), html_options)
      else
        name
      end
    end
  end
  
  def link_if_allowed_fancy(*args, &block)
    if block_given?
      html_options = args.second || {}
      html_options[:fancy] = true
      link_if_allowed(args.first, html_options, &block)
    else
      html_options = args.third || {}
      html_options[:fancy] = true
      link_if_allowed(args.first, args.second, html_options)
    end
  end
  
  def link_in_li_if_allowed(*args, &block)
    out = link_if_allowed(*args, &block)
    out.blank? ? "" : content_tag(:li, out)
  end
  
  # needs include_fancy_box and #login_fancybox div inside a hidden div in layout
  def link_to_login_fancybox(*args, &block)
    if block_given?
      html_options = get_fancy_options(args.first || {})
      link_to("#login_fancybox", html_options, &block)
    else
      html_options = get_fancy_options(args.second || {})
      link_to(args.first, "#login_fancybox", html_options)
    end
  end
  
  def link_to_remote_if_allowed(name, options = {}, html_options = nil)
    url_proc = options.delete(:url)
    show_fancybox = options.delete(:fancy)
    ActiveSupport::Deprecation.warn("PermissionsHelper#allowed_to? should take a Proc for its first argument rather than a hash, eg. page_proc(page). This will make Tramlines run much faster!!!", caller) if url_proc.is_a?(Hash)
    if allowed_to?(url_proc, options)
      link_to_remote(name, options.merge(:url => resolve_path(url_proc)), html_options)
    else
      show_fancybox ? link_to_login_fancybox(name, html_options) : ""
    end
  end
  
  def link_to_remote_if_allowed_fancy(name, options = {}, html_options = nil)
    link_to_remote_if_allowed(name, options.merge(:fancy => true), html_options)
  end
  
  def link_to_box_if_allowed(name, url_proc, options = {})
    return "" if !allowed_to?(url_proc)
    link_to_box(name, resolve_path(url_proc), options)
  end
  
  private
  def get_url_hash(url_proc_or_hash)
    path = resolve_path(url_proc_or_hash)
    path.is_a?(String) ? path : url_for(path)
  end
  
  def proc_for(obj)
    send("#{obj.class.to_s.underscore.gsub(/\//, '_')}_proc", obj)
  end
  
  def resolve_path(url_proc_or_hash, method = nil)
    if url_proc_or_hash.is_a?(Proc)
      url_proc_or_hash.call(:path)
    else
      url_proc_or_hash
    end
  end
  
end
