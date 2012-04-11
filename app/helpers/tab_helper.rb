# the tab contents are defined in partials located in default directory "#{action_name}_tabs"
# e.g
# tramlines_tabs(:tabs => %w{page snippets publishing}, :tab_directory => 'form_tabs', :locals => {:page => @page})
# options include :tabs(defines order), :tab_directory, :tab_loader, :container_id, :locals(used in tab partials)
#
# page#new has a good example

module TabHelper

  INLINE_ERROR_RE = /<p class="inline-errors">/

  def tramlines_tabs(options = {})
    javascript_for_tabs
    options[:tabs] = options[:tabs].reject(&:blank?) || []
    options[:controller] = controller
    tabbed_form = TabbedForm.new(self, options)
    tabbed_form.render
  end
  
  private
  def javascript_for_tabs
    content_for :head do
      javascript_tag do
        "var TabForm = {
          hide_other_tabs: function(tab_id) {
            $('.#{controller_name}_tab:not(#'+tab_id+')').hide();            
          },
          set_active_tab: function(tab_id) {
            $('ul.tabs_container li').removeClass('active');
            $('#'+tab_id.replace('_tab', '_link')).addClass('active');
          },
          show_tab: function(tab_id) {
            TabForm.set_active_tab(tab_id);
            TabForm.hide_other_tabs(tab_id);
            $('#'+tab_id).show();
          },
          show_tab_with_loader: function(tab_id) {
            $('#tab_loader').show();
            TabForm.show_tab(tab_id);
          }
        };"
      end
    end
  end

  class Tab

    extend ActiveSupport::Memoizable
    
    attr_reader :name, :validate
    
    def hidden?
      @validate && !@open
    end
    
    def initialize(name, template, options)
      @name, @template, @tab_directory, @locals, @validate, @controller_view_path = name, template, options[:tab_directory], options[:locals], options[:validate], options[:controller_view_path]
      @url_options = options[:url_options].merge(:tab_directory => @tab_directory, :tab_name => @name, :validate => @validate)
    end
    
    def render
      @template.render(:partial => partial_path, :locals => (@locals || {}).merge(:tab_name => @name))
    end
    memoize :render

    def render_tab_link(open)
      @open = open
      if @open || hidden?
        tab_link_to_function
      else
        tab_link_to_remote
      end
    end
    
    private    
    def classes
      returning out = [] do
        if @open
          out << 'active'
        elsif invalid?
          out << 'invalid'
        end
      end
    end
    
    def classes_string
      classes.join ' '
    end
    
    # Recursively encode locals into a hash
    def encoded_local_params(local_params_hash, container = nil)
      local_params_hash.map do |key, val|
        key = "#{container}[#{key}]" if !key.nil?
        if val.is_a?(Hash)
          encoded_local_params(val, key)
        else
          "#{ERB::Util::url_encode(key)}=#{ERB::Util::url_encode(val)}"
        end
      end.flatten
    end
    
    def encoded_locals
      "'#{encoded_local_params(local_params).join('&')}'"
    end
    memoize :encoded_local_params
    
    def invalid?
      !valid?
    end
    
    def local_params
      @locals ||= {}
      @locals.inject({}) do |memo, (name, value)|
        if value.is_a?(ActiveRecord::Base)
          memo["#{name}_class"] = value.class.to_s.gsub("::", "_")
          memo["#{name}_attributes"] = value.attributes
        else
          memo[name] = value
        end
        memo
      end
    end
    
    def partial_path
      tab_partial_path = "#{@controller_view_path}/#{@tab_directory}/#{@name}"
      Rails.logger.info "@template.partial_exists?(#{tab_partial_path}) = #{@template.partial_exists?(tab_partial_path)}"
      @template.partial_exists?(tab_partial_path) ? tab_partial_path : "#{@controller_view_path}/#{@tab_directory}/default"
    end
    memoize :partial_path
    
    def tab_link_to_function(options = {})
      options = {:id => with_tab_prefix("#{@name}_link"), :class => (classes_string + options[:class].to_s)}
      @template.content_tag(:li, @template.link_to_function(@name.humanize, "TabForm.show_tab('#{with_tab_prefix(@name)}_tab');"), options)
    end
    memoize :tab_link_to_function

    def tab_link_to_remote
      options = {:id => with_tab_prefix("#{@name}_link"), :class => classes_string}
      @template.content_tag(:li, @template.link_to_remote(@name.humanize, 
                            :url => @url_options, 
                            :before => "$(this).parent().replaceWith('#{@template.escape_javascript(tab_link_to_function(:class => 'active'))}'); TabForm.show_tab_with_loader('#{with_tab_prefix(@name)}_tab');", 
                            :complete => "$('#tab_loader').hide();", 
                            :with => encoded_locals), options)
    end
    memoize :tab_link_to_remote

    def valid?
      !@validate || (render =~ INLINE_ERROR_RE).nil?
    end
    memoize :valid?
    
    def with_tab_prefix(text)
      "#{@controller_view_path}_#{text}"
    end
    
  end
  
  class TabbedForm
    
    extend ActiveSupport::Memoizable
    
    def initialize(template, options)
      @template, @controller, @tab_directory, @locals, @container_id, @loader_filename = template, options[:controller], options[:tab_directory], options[:locals], options[:container_id], options[:tab_loader]
      @loaded_tabs = [*options[:loaded_tabs]] || []
      url_options = {:controller => controller_view_path, :action => "tab", :tab_directory => @tab_directory}
      if options[:validate]
        validate_locals
        @validate = true
      else
        @validate = perform_validation?
      end
      @tabs = options[:tabs].map {|tab_name| Tab.new(tab_name, @template, :url_options => url_options, :locals => @locals, :tab_directory => @tab_directory, :validate => (@validate || @loaded_tabs.include?(tab_name)), :controller_view_path => controller_view_path)}
      make_tab_open(options[:open_tab]) if options[:open_tab]
    end

    def render
      returning out = '' do
        out << tab_links
        @tabs.each do |tab|
          out << render_tab(tab) if tab.validate || tab==open_tab
        end
        
        # if @validate
        #   # We need to render all tabs, so that any already-set values get passed
        #   @tabs.each do |tab|
        #     out << render_tab(tab)
        #   end
        # else
        #   out << render_tab(tab)
        # end
        out << loader(@loader_filename)
      end
    end
    memoize :render

    def render_tab(tab_or_name)
      tab  = tab_or_name.is_a?(Tab) ? tab_or_name : @tabs.detect {|tab| tab.name == tab_or_name}
      options = {:id => "#{with_tab_prefix(tab.name)}_tab", :class => "#{with_tab_prefix('tab')} tramlines_tab"}
      options[:style] = "display: none;" if tab.hidden?
      @template.content_tag(:div, tab.render, options)
    end
    memoize :render_tab

    private
    def controller_view_path
      @controller.controller_name
    end
    
    def loader(filename)
      filename ||= 'ajax_loader.gif'
      @template.content_tag(:div, @template.image_tag(filename) + @template.content_tag(:br, "", :class => "clear"), :id => 'tab_loader', :style => 'display:none')
    end
    
    def make_tab_open(tab_name)
      @open_tab = @tabs.detect {|tab| tab.name == tab_name}
    end
    
    def open_tab
      @open_tab ||= @tabs.detect(&:invalid?) || @tabs.first
    end
    
    def open_tab_name
      open_tab.name
    end
    
    def perform_validation?(vars = @locals)
      return false if vars.nil?
      vars.any? do |key, value|
        if value.respond_to?(:errors)
          !value.errors.empty?
        elsif value.is_a?(Hash)
          perform_validation?(value)
        end
      end
    end
    memoize :perform_validation?
    
    def tab_is_open?(tab)
      open_tab == tab
    end
    
    def tab_links
      html = @template.content_tag :ul, :id => @container_id, :class => 'tabs_container' do
        @tabs.inject(out = '') do |out, tab|
          out + tab.render_tab_link(tab_is_open?(tab))
        end
      end
      html + @template.content_tag(:br, "", :class => "clear", :id => with_tab_prefix("tab_links_break"))
    end
    memoize :tab_links
    
    def validate_locals(vars = @locals)
      vars.each do |key, value|
        if value.respond_to?(:valid?)
          value.valid?
        elsif value.is_a?(Hash)
          validate_locals(value)
        end
      end
    end
    memoize :validate_locals
    
    def with_tab_prefix(text)
      "#{controller_view_path}_#{text}"
    end    

  end

end
