# Set the default text field size when input is a string. Default is 50.
# Formtastic::SemanticFormBuilder.default_text_field_size = 50

# Set the default text area height when input is a text. Default is 20.
# Formtastic::SemanticFormBuilder.default_text_area_height = 5

# Should all fields be considered "required" by default?
# Defaults to true, see ValidationReflection notes below.
# Formtastic::SemanticFormBuilder.all_fields_required_by_default = true

# Should select fields have a blank option/prompt by default?
# Defaults to true.
# Formtastic::SemanticFormBuilder.include_blank_for_select_by_default = true

# Set the string that will be appended to the labels/fieldsets which are required
# It accepts string or procs and the default is a localized version of
# '<abbr title="required">*</abbr>'. In other words, if you configure formtastic.required
# in your locale, it will replace the abbr title properly. But if you don't want to use
# abbr tag, you can simply give a string as below
# Formtastic::SemanticFormBuilder.required_string = "(required)"

# Set the string that will be appended to the labels/fieldsets which are optional
# Defaults to an empty string ("") and also accepts procs (see required_string above)
# Formtastic::SemanticFormBuilder.optional_string = "(optional)"

# Set the way inline errors will be displayed.
# Defaults to :sentence, valid options are :sentence, :list and :none
# Formtastic::SemanticFormBuilder.inline_errors = :sentence

# Set the method to call on label text to transform or format it for human-friendly
# reading when formtastic is user without object. Defaults to :humanize.
# Formtastic::SemanticFormBuilder.label_str_method = :humanize

# Set the array of methods to try calling on parent objects in :select and :radio inputs
# for the text inside each @<option>@ tag or alongside each radio @<input>@. The first method
# that is found on the object will be used.
# Defaults to ["to_label", "display_name", "full_name", "name", "title", "username", "login", "value", "to_s"]
# Formtastic::SemanticFormBuilder.collection_label_methods = [
#   "to_label", "display_name", "full_name", "name", "title", "username", "login", "value", "to_s"]

# Formtastic by default renders inside li tags the input, hints and then
# errors messages. Sometimes you want the hints to be rendered first than
# the input, in the following order: hints, input and errors. You can
# customize it doing just as below:
Formtastic::SemanticFormBuilder.inline_order = [:help, :input, :loader, :hints, :errors]

# Specifies if labels/hints for input fields automatically be looked up using I18n.
# Default value: false. Overridden for specific fields by setting value to true,
# i.e. :label => true, or :hint => true (or opposite depending on initialized value)
# Formtastic::SemanticFormBuilder.i18n_lookups_by_default = false

# You can add custom inputs or override parts of Formtastic by subclassing SemanticFormBuilder and
# specifying that class here.  Defaults to SemanticFormBuilder.
Formtastic::SemanticFormHelper.builder = TramlinesSemanticFormBuilder

Formtastic::SemanticFormBuilder.class_eval do

  # Generates help for the given method using the text supplied in :help.
  #
  def inline_help_for(method, options) #:nodoc:
    options[:help] = localized_string(method, options[:help], :help)
    return if options[:help].blank?
    template.content_tag(:p, options[:help], :class => 'inline-help')
  end

  def inline_loader_for(method, options) #:nodoc:
    return if options[:loader].blank?
    html_id = options[:id].blank? ? generate_html_id(method, "loader") : "#{options[:id]}_loader"
    template.image_tag(options[:loader], :id => html_id, :style => "display:none")
  end

  def input_with_tramlines(method, options = {})
    options = options.dup
    if options[:label] == false
      options[:wrapper_html] ||= {}
      options[:wrapper_html][:class] = "#{options[:wrapper_html][:class]} no_label".strip
    end
    input_without_tramlines(method, options)
  end
  alias_method_chain :input, :tramlines

  def commit_button_with_loader(*args)
    commit_button_in_li = commit_button_without_loader(*args)
    options = args.extract_options!
    return commit_button_in_li if options[:loader].blank?
    options[:loader_html] ||= {}
    if options[:button_html].nil? || options[:button_html][:id].blank?
      loader_id = "commit_loader"
    else
      loader_id = "#{options[:button_html][:id]}_loader"
    end
    options[:loader_html].reverse_merge!(:id => loader_id, :style => "display:none")
    loader = template.image_tag(options[:loader], options[:loader_html])
    commit_button_in_li.sub(/<\/li>$/, "#{loader}</li>")
  end
  alias_method_chain :commit_button, :loader

  def check_boxes_input_with_other(method, options)
    return check_boxes_input_without_other(method, options) if !options[:include_other]
    collection = find_collection_for_column(method, options)
    html_options = options.delete(:input_html) || {}

    #formtastic stuff
    input_name      = generate_association_input_name(method)
    value_as_class  = options.delete(:value_as_class)
    unchecked_value = options.delete(:unchecked_value) || ''
    html_options    = { :name => "#{@object_name}[#{input_name}][]" }.merge(html_options)
    input_ids       = []
    selected_option_is_present = [:selected, :checked].any? { |k| options.key?(k) }
    selected_values = (options.key?(:checked) ? options[:checked] : options[:selected]) if selected_option_is_present
    selected_values  = [*selected_values].compact
    disabled_option_is_present = options.key?(:disabled)
    disabled_values = [*options[:disabled]] if disabled_option_is_present
    list_item_content = collection.map do |c|
      label = c.is_a?(Array) ? c.first : c
      value = c.is_a?(Array) ? c.last : c
      input_id = generate_html_id(input_name, value.to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase)
      input_ids << input_id
      html_options[:checked] = selected_values.include?(value) if selected_option_is_present
      html_options[:disabled] = disabled_values.include?(value) if disabled_option_is_present
      html_options[:id] = input_id
      li_content = template.content_tag(:label,
      Formtastic::Util.html_safe("#{self.check_box(input_name, html_options, value, unchecked_value)} #{escape_html_entities(label)}"),
      :for => input_id)
      li_options = value_as_class ? { :class => [method.to_s.singularize, value.to_s.downcase].join('_') } : {}
      template.content_tag(:li, Formtastic::Util.html_safe(li_content), li_options)
    end
    
    #"other" stuff
    input_id = generate_html_id(input_name, "other_selector")
    html_options[:id] = input_name
    current_values = (@object.nil? ? nil : @object.send(method)) || []
    other_value = (current_values - (collection << "Other")).reject(&:blank?).compact.first
    other_label = options[:include_other]==true ? "Other (please specify...)" : options[:include_other]
    other_field_id = "#{self.object.class.to_s.underscore}_#{input_name}_other"
    
    html_options[:onclick] = "$('##{other_field_id}').attr('disabled', !this.checked).focus();"
    
    other_text_field = self.text_field_tag("#{self.object.class.to_s.underscore}[#{input_name}][]", other_value, :id => other_field_id, :size => 50, :disabled => !current_values.include?("Other"))
    
    other = template.content_tag(:label, "#{self.check_box(input_name, html_options, "Other", unchecked_value)} #{other_label} #{other_text_field}", :for => input_id)
    list_item_content << template.content_tag(:li, other)

    fieldset_content = legend_tag(method, options)
    fieldset_content << template.content_tag(:ol, Formtastic::Util.html_safe(list_item_content.join))
    template.content_tag(:fieldset, fieldset_content)
  end
  alias_method_chain :check_boxes_input, :other

  def select_input_with_other(method, options)
    return select_input_without_other(method, options) if !options[:include_other]
    string_options = options.dup.merge(:label => false)
    string_options[:input_html] = (string_options[:input_html] || {}).merge(:class => "other_input_for_select")
    options[:input_html] = (options[:input_html] || {}).merge(:onchange => "FormtasticSelectWithOther.toggleOther($(this));")
    other_label = options[:include_other]==true ? "Other" : options[:include_other]
    options[:collection] = [*find_collection_for_column(method, options)] + [[other_label, "other"]]
    collection_values = options[:collection].collect {|c| c.is_a?(Array) ? c.second : c}
    current_value = @object.nil? ? nil : @object.send(method)
    if @object && (current_value.blank? ? (!options[:include_blank] && !@object.errors.empty?) : !collection_values.include?(current_value))
      options[:selected] = "other"
      options[:input_html].merge!(:name => "ignore_this")
    else
      string_options[:input_html].merge!(:style => "display:none", :name => "ignore_this")
    end
    out = select_input_without_other(method, options)
    out << string_input(method, string_options)
  end
  alias_method_chain :select_input, :other

  def sub_label(method, options_or_text=nil, options=nil)
    if options_or_text.is_a?(Hash)
      return "" if options_or_text[:sub_label].nil?
      options = options_or_text
      text = options.delete(:sub_label)
    else
      text = options_or_text
      options ||= {}
      return '' if text.nil?
    end
    text = localized_string(method, text, :sub_label)
    text += required_or_optional_string(options.delete(:required))
    text = Formtastic::Util.html_safe(text)

    # special case for boolean (checkbox) labels, which have a nested input
    if options.key?(:label_prefix_for_nested_input)
      text = options.delete(:label_prefix_for_nested_input) + text
    end
    input_name = options.delete(:input_name) || method
    options[:class] = 'sub'
    label(input_name, text, options)
  end


  private
  def basic_input_helper(form_helper_method, type, method, options) #:nodoc:
    html_options = options.delete(:input_html) || {}
    html_options = default_string_options(method, type).merge(html_options) if [:numeric, :string, :password, :text].include?(type)
    self.label(method, options_for_label(options)) <<
    self.sub_label(method, options_for_sub_label(options)) <<
    self.send(form_helper_method, method, html_options)
  end

  # Prepare options to be sent to sub_label
  #
  def options_for_sub_label(options) #:nodoc:
    options.slice(:sub_label, :required).merge!(options.fetch(:sub_label_html, {}))
  end


end