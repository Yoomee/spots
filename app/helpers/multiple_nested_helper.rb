module MultipleNestedHelper
  
  def multiple_nested_inputs_for(attribute, options = {})
    parent = options[:form].object
    child_name = options[:child_name] ||=  attribute.to_s.singularize
    options.reverse_merge!(:label => child_name,
                           :partial => "#{parent.class.to_s.underscore.pluralize}/#{child_name}_form", 
                           :add_link_text => "Add #{child_name.humanize.downcase}",
                           :collection => parent.send(attribute),
                           :parent_association_name => parent.class.to_s.underscore,
                           :warn_before_delete => false)
    html = options[:label] ? content_tag(:li, label_tag(attribute, options[:label]), :id => "#{child_name}_label", :class => "multiple_nested_label") : ""
    html << "<li id='#{child_name}_inputs' class='multiple_nested_inputs'>"
    options[:collection].each do |child|
      html << render(options[:partial], :form => options[:form], child_name.to_sym => child)
    end
    html << link_to_function(options[:add_link_text], "#{parent.class.to_s}#{child_name.camelize}Form.add()", :id => "add_#{child_name}_link", :class => "multiple_nested_add_link")
    html << "</li>"
    html << multiple_nested_javascript_for(attribute, options)
    html
  end
  
  def multiple_nested_javascript_for(attribute, options = {})
    child_name = options[:child_name] ||= attribute.to_s.singularize
    callback = options[:callback] || "function() {return true;}"
    parent = options[:form].object
    options.reverse_merge!(:partial => "#{parent.class.to_s.underscore.pluralize}/#{child_name}_form", :warn_before_delete => true)
    child_instance = parent.send(attribute).build
    child_instance.send("#{options[:parent_association_name]}=", parent) if child_instance.respond_to?("#{options[:parent_association_name]}=")
    json_name = "#{parent.class.to_s}#{child_name.camelize}Form"
    javascript_tag do
      "var #{json_name} = {
        count: 0,
        add: function() {
          var html = '#{escape_javascript(render("#{options[:partial]}", :form => options[:form], child_name.to_sym => child_instance))}';
          var last_num = parseInt(html.match(/#{attribute}_attributes_(\\d)_/)[1]);
          var current_num = last_num + #{json_name}.count;
          html = html.replace(/#{attribute}_attributes_\\d_/g,'#{attribute}_attributes_' + current_num + '_');
          html = html.replace(/\\[#{attribute}_attributes\\]\\[\\d\\]/g,'[#{attribute}_attributes][' + current_num + ']');
          #{json_name}.count += 1;
          $('#add_#{child_name}_link').before(html);
          #{options[:labelify] ? "$('.labelify').labelify({ labelledClass: 'labelified' });" : ''}
          if ($.fancybox != undefined) {$.fancybox.resize();}
          this.callback();
        },
        callback: #{callback},
        deleteItem: function(delete_link) {
          delete_link.parent().prev('.multiple_nested_destroy').children('input').attr('value','1');
          delete_link.parents('.multiple_nested_inputs fieldset').hide();
          if ($.fancybox != undefined) {$.fancybox.resize();}          
        }, 
        remove: function(delete_link) {
          if (#{options[:warn_before_delete]}) {
            if (confirm('Are you sure?')) {
              #{json_name}.deleteItem(delete_link);
            }
          } else {
            #{json_name}.deleteItem(delete_link);
          }
          return true;
        },
        hide_items_marked_for_destroy: function() {
          $('.multiple_nested_destroy input').each(function() {
            if ($(this).attr('value') == '1') {
              $(this).parents('.multiple_nested_inputs fieldset').hide();
            }
          });
        }
        // has_inputs_with_values: function(container) {
        //   inputs = container.find('input.facelist-values, input:visible:not(.as-input), textarea:visible, select:visible').filter(function() { 
        //     return $(this).val() != '';
        //   });
        //   return inputs.length != 0;
        // }
      };
      $(document).ready(function() {
        #{json_name}.hide_items_marked_for_destroy();
      });"
    end
  end
  
  def multiple_nested_delete_link_for(attribute, options = {})
    options.reverse_merge!(:text => "x")
    html = options[:form].input(:_destroy, :as => :hidden, :wrapper_html => {:class => "multiple_nested_destroy"})
    html << content_tag(:li, link_to_function(options[:text], "#{options[:parent_name].camelize}#{attribute.to_s.camelize}Form.remove($(this))"), :class => "remove_link")
  end
  
end