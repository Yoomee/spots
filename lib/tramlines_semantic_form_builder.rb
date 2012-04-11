class TramlinesSemanticFormBuilder < Formtastic::SemanticFormBuilder

  # TODO: this is currently only designed to work with one input
  # uses TramlinesAutocomplete (found in public/application.js)
  # also uses public/javascripts/jquery.facelist_2-0.js and public/stylesheets/facelist_2-0.css
  def fb_autocomplete_input(method, options)    
    html_options = options.delete(:input_html) || {}
    hidden_html_options = options.delete(:hidden_input_html) || {}
    input_name = generate_association_input_name(method)
    html_options[:id] ||= generate_html_id(input_name, "")
    hidden_html_options[:id] ||= "#{html_options[:id]}"
  
    template.javascript_include_tag_once("jquery.facelist_2-0")
    template.stylesheet_link_tag_once("facelist_2-0")
  
    autocomplete_object = @object.send(method)
    extra_search_params = "&models=#{(options[:models] || self.reflection_for(method).class_name)}"
    (options.delete(:with) || {}).each do |key, value|
      extra_search_params += "&with%5B#{key}%5D=#{value}"
    end
    extra_search_params += "&add_new_option=1" if options.delete(:add_new_option)
    unique_id = "autocomplete_#{html_options[:id]}"
    autocomplete_html = javascript_tag("
      $(document).ready(function() {
        $('##{unique_id}').faceList('#{template.send(:formtastic_autocomplete_new_search_path)}', {
          returnID: '#{unique_id}',
          minChars: 2,
          intro_text: '#{options.delete(:prompt).to_s}',
          no_result: '#{options.delete(:no_result) || 'No Results Found'}',
          queryParam: 'term',
          extraParams: '#{extra_search_params}',
          searchObj: 'value',
          selectedItem: 'value',
          selectedValues: 'id',
          selectionLimit: 1,
          limit_warning: 'Only one can be selected',
          start_value: [#{autocomplete_object.nil? || autocomplete_object.new_record? ? '' : {:id => autocomplete_object.id.to_s, :value => autocomplete_object.to_s}.to_json}],
          start: function() {
            #{autocomplete_object.nil? || autocomplete_object.new_record? ? 'return true;' : 'TramlinesAutocomplete.addSelectionMadeClass($(this));'}
          },
          resultsComplete: function() {
            TramlinesAutocomplete.searchedValue = $('##{hidden_html_options[:id]}').parents('li.fb_autocomplete').find('input.as-input:first').val();
          },
          resultClick: function(data) {
            if (data.attributes.add_new_option == undefined) {
              #{options.delete(:result_click) || 'TramlinesAutocomplete.addSelectionMadeClass($(this));'}              
            } else {
              $(this).children('.fb_autocomplete_add_new_option').click();
            }
          },
          itemRemoved: function(item) {
            #{options.delete(:item_removed) || 'TramlinesAutocomplete.removeSelectionMadeClass($(this));'}
          }
        });
        $('##{hidden_html_options[:id]}').parents('form:first').attr('onSubmit', 'TramlinesAutocomplete.save_fb_autocompletes();')
      });")
    autocomplete_html << self.hidden_field(input_name, hidden_html_options)
    autocomplete_html << text_field_tag(unique_id, @object.send(method).to_s, html_options.merge(:autocomplete => "off", :id => unique_id))
    label_options = options_for_label(options).merge(:input_name => input_name)
    label_options[:for] ||= html_options[:id]
    self.label(method, label_options) << autocomplete_html
  end

  def autocomplete_input(method, options)
    html_options = options.delete(:input_html) || {}
    hidden_html_options = options.delete(:hidden_input_html) || {}
    input_name = generate_association_input_name(method)
    html_options[:id] ||= generate_html_id(input_name, "")
    hidden_html_options[:id] ||= "#{html_options[:id]}_hidden"    
    
    autocomplete_html = javascript_tag(
      "$(document).ready(function() {
          $('##{html_options[:id]}').autocomplete({
            source: '#{template.send(:formtastic_autocomplete_new_search_path, :models => self.reflection_for(method).class_name, :with => options.delete(:with))}',
            delay: 500,
            minLength: 2,
            select: function(event, ui) {
              $('##{hidden_html_options[:id]}').val(ui.item.id);
              $('##{html_options[:id]}').val(ui.item.value);
              #{options[:after_select]};
            }
          });
        });")
    autocomplete_html << self.hidden_field(input_name, hidden_html_options)
    unique_id = "autocomplete_#{method}"    
    if res = hidden_html_options[:id].match(/attributes_(\d)_/)
      unique_id << "_#{res[1]}"
    end
    autocomplete_html << text_field_tag(unique_id, @object.send(method).to_s, html_options.merge(:autocomplete => "off"))
    label_options = options_for_label(options).merge(:input_name => input_name)
    label_options[:for] ||= html_options[:id]
    self.label(method, label_options) << autocomplete_html
  end

  def basic_options_input_helper(form_helper_method, type, method, options_string, options) #:nodoc:
    html_options = options.delete(:input_html) || {}
    html_options = default_string_options(method, type).merge(html_options) if [:numeric, :string, :password, :text, :phone, :search, :url, :email].include?(type)
    field_id = generate_html_id(method, "")
    html_options[:id] ||= field_id
    label_options = options_for_label(options)
    label_options[:for] ||= html_options[:id]
    label(method, label_options) <<
      send(respond_to?(form_helper_method) ? form_helper_method : :select, method, options_string, html_options)
  end
  
  def ck_text_input(method, options)
    basic_input_helper(:cktext_area, :text, method, options)
  end

  def image_input(method, options)
    options.reverse_merge!(:remove_input => false)
    img_size = options.delete(:image_size) || "100x"
    out = self.label(method, options_for_label(options).merge(:class => 'image_label'))
    if @object && !@object.send(method).nil? && !@object.errors.invalid?(method) && !@object.errors.invalid?("#{method}_uid")
      out << image_tag(@object.send(method).process(:thumb, img_size).url, :class => "image_file_preview")
    end
    out << self.send(:file_field, method, options.delete(:input_html) || {})
    if options[:remove_input] && @object && !@object.send(method).nil?
      label_text = options[:remove_label].presence || "Remove #{(options[:label].presence || 'image').downcase}"
      out << self.boolean_input("remove_#{method}", :label => label_text) 
    end
    out
  end
  
  def options_select(method, options_string, options = {}, html_options = {})
    @template.options_select(@object_name, method, options_string, objectify_options(options), @default_options.merge(html_options))
  end

  def tramlines_date_input(method, options)
    options.reverse_merge!(:start_year => Time.now.year, :end_year => 5.years.from_now.year, :order => [:day, :month, :year], :labels => {:day => "", :month => "", :year => ""}, :prompt => {:day => "Day", :month => "Month", :year => "Year"})
    date_input(method, options)
  end

end
