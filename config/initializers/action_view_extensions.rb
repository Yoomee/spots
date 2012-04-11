ActionView::Helpers::FormOptionsHelper.module_eval do
  
  def options_select(object, method, options_string, options = {}, html_options = {})
    ActionView::Helpers::InstanceTag.new(object, method, self, options.delete(:object)).to_options_select_tag(options_string, options, html_options)
  end
  
end

ActionView::Helpers::InstanceTag.class_eval do
  
  def to_options_select_tag(options_string, options, html_options)
    html_options = html_options.stringify_keys
    add_default_name_and_id(html_options)
    content_tag("select", add_options(options_string, options), html_options)
  end
  
end

ActionView::Helpers::TextHelper.module_eval do
  
  private
  def auto_link_email_addresses(text, html_options = {})
    body = text.dup
    text.gsub(/([\w\.!#\$%\-+.]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)+)/) do
      text = $1

      if body.match(/<a\b[^>]*>(.*)(#{Regexp.escape(text)})(.*)<\/a>/) || body.match(/href=[\"\']mailto:\s*#{Regexp.escape(text)}/)
        text
      else
        display_text = (block_given?) ? yield(text) : text
        mail_to text, display_text, html_options
      end
    end
  end
  
end

ActionView::Helpers::UrlHelper.module_eval do

  def current_page?(options)
     url_string = CGI.unescapeHTML(url_for(options))
     request = @controller.request
     # We ignore any extra parameters in the request_uri if the 
     # submitted url doesn't have any either.  This lets the function
     # work with things like ?order=asc 
     if !request.env['REQUEST_PATH'].blank?
       request_uri = request.env['REQUEST_PATH']
     else
       request_uri = request.request_uri
     end
     if !url_string.index("?")
       request_uri = request_uri.split('?').first
     end
     if url_string =~ /^\w+:\/\//
       url_string == "#{request.protocol}#{request.host_with_port}#{request_uri}"
     else
       url_string == request_uri
     end
   end

   unless method_defined?(:link_to_without_prefixing)

     def link_to_function_with_prefixing(name, *args, &block)
       html_options = args.extract_options!.symbolize_keys
       prefix = html_options.delete(:prefix)
       suffix = html_options.delete(:suffix)
       "#{prefix ? content_tag(:span, prefix, :class => 'prefix') : ''}#{link_to_function_without_prefixing(name, *args << html_options, &block)}#{suffix ? content_tag(:span, suffix, :class => 'suffix') : ''}"
     end
     alias_method_chain :link_to_function, :prefixing

     def link_to_remote_with_block(*args, &block)
     #def link_to_remote_with_block(name, options = {}, html_options = nil, &block)
       if block_given?
         options = args.first
         html_options = args.second || options.delete(:html) || {}
         concat(link_to_remote_without_block(capture(&block), options, html_options))
       else
         link_to_remote_without_block(args.first, args.second, args.third)
       end
     end
     alias_method_chain :link_to_remote, :block

     def link_to_with_prefixing(*args, &block)
       if block_given?
         options = args.first || {}
         html_options = args.second || {}
         prefix = html_options.delete(:prefix)
         suffix = html_options.delete(:suffix)
         "#{prefix ? content_tag(:span, prefix, :class => 'prefix') : ''}#{link_to_without_prefixing(options, html_options, &block)}#{suffix ? content_tag(:span, suffix, :class => 'suffix') : ''}"
       else
         name = args.first
         options = args.second || {}
         html_options = args.third || {}
         prefix = html_options.delete(:prefix)
         suffix = html_options.delete(:suffix)
         "#{prefix ? content_tag(:span, prefix, :class => 'prefix') : ''}#{link_to_without_prefixing(name, options, html_options)}#{suffix ? content_tag(:span, suffix, :class => 'suffix') : ''}"
       end
     end
     alias_method_chain :link_to, :prefixing

     def my_link_to(*args, &block)
       if block_given?
         options      = args.first || {}
         html_options = args.second
         concat(link_to(capture(&block), options, html_options))
       else
         name         = args.first
         options      = args.second || {}
         html_options = args.third

         url = url_for(options)

         if html_options
           html_options = html_options.stringify_keys
           href = html_options['href']
           convert_options_to_javascript!(html_options, url)
           tag_options = tag_options(html_options)
         else
           tag_options = nil
         end

         href_attr = "href=\"#{url}\"" unless href
         "<a #{href_attr}#{tag_options}>#{name || url}</a>".html_safe
       end
     end

     def my_link_to_function(name, *args)
       html_options = args.extract_options!.symbolize_keys
       function = remote_function(options)
       onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function}; return false;"
       href = html_options[:href] || '#'
       content_tag(:a, name, html_options.merge(:href => href, :onclick => onclick))
     end

   end

end

ActionView::Template.class_eval do

  #TODO: check efficiency of this method
  def fbml_view_exists?
    ApplicationController.view_paths.each do |view_path|
      return true if File.exists?("#{RAILS_ROOT}/#{view_path}/#{path_without_fbml_check}")
    end
    false
  end
  
  def path_with_fbml_check
    if format == "fbml" && !fbml_view_exists?
      format = "html"
      path_without_fbml_check
    else
      path_without_fbml_check
    end
  end
  alias_method_chain :path, :fbml_check
  
end

ENV['RAILS_ASSET_ID'] = '' if RAILS_ENV == 'development'
