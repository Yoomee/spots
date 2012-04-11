module FormHelper

  def add_child_function(container_id, f, method, options = {})
    fields = new_child_fields(f, method, options)
    "FormHelper.insert_fields($('##{container_id}'), '#{method}', '#{escape_javascript(fields)}');"
  end
  
  def add_remove_child_javascript
    javascript_tag do
      "var FormHelper = {
        insert_fields: function(container, method, content) {
          var new_id = new Date().getTime();
          var regexp = new RegExp('new_' + method, 'g');          
          container.append(content.replace(regexp, new_id));
        },
        remove_fields: function(link) {
          var delete_field = $(link).parent().find('input[id$=_destroy]')[0];
          if (delete_field) {
            delete_field.value = '1';
          }
          $(link).closest('.fields').hide();
        }
      };"
    end
  end
  
  def alert_on_exit_javascript(options = {})
    options.reverse_merge!(:message => "WARNING - UNSAVED DATA.\\nIf you leave this page all changes will be lost.")
    javascript_tag do
      "var made_changes = false;
       $(window).bind('beforeunload', function() {
         if (made_changes) {
           return '#{options[:message]}';
         }
       });
       $(document).ready(function() {
         $('##{options[:form_id]}').submit(function() {
           made_changes = false;
         });
         $('##{options[:form_id]} input, ##{options[:form_id]} textarea, ##{options[:form_id]} select').change(function() {
           made_changes = true;
         });
       });"
    end
  end
  
  def datepicker_javascript(options = {})
    out = options.delete(:with_time) ? javascript_include_tag('timepicker.js') : ""    
    extra_options = options.keys.inject({}) {|opts, key| opts[key.to_s.camelize(:lower)] = options[key]; opts}
    extra_options.reverse_merge!("duration" => '', "dateFormat" => 'dd/mm/yy', "showTime" => true, "constrainInput" => false, "stepMinutes" => 1, "stepHours" => 1, "altTimeField" => '', "time24h" => true)
    out + javascript_tag do 
      "function init_datepickers(identifier) {
        if (typeof(identifier) == 'undefined') {identifier = '.datetime';}
        $(identifier).datepicker(#{extra_options.to_json});
       }
       $(document).ready(function() {
         init_datepickers('.datetime');
       });"
    end
  end
  
  def labelify_javascript(options = {})
    options.reverse_merge!(:script_tag => true)
    out = "$(document).ready(function() {
              if ($('.labelify').length > 0) {
                $('.labelify').labelify({ labelledClass: 'labelified' });
              }
           });"
    options[:script_tag] ? javascript_tag(out) : out
  end
  
  def new_child_fields(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f
    form_builder.semantic_fields_for(method, options[:object], :child_index => "new_#{method}") do |f|
      render(:partial => options[:partial], :locals => { options[:form_builder_local] => f})
    end
  end  
  
  def semantic_remote_or_not_form_for(record_or_name_array, remote, *args, &proc)
    remote ? semantic_remote_form_for(record_or_name_array, *args, &proc) : semantic_form_for(record_or_name_array, *args, &proc)
  end      

  # Method to render a star to show a field is mandatory
  def star
    "<span class='required'>*</span>"
  end
  
end
