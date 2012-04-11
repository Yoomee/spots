class Search

  DEFAULT_OPTIONS = {
    :match_mode => :all,
    :with => {}
  }

  attr_reader :term, :conditions, :with
  cattr_reader :enquiry_forms
  extend ActiveSupport::Memoizable
  
  class << self
    
    # every searchable model
    def all_possible_models
      ThinkingSphinx::context.indexed_models.map(&:to_s)      
    end
    
    # default models that should be searched, overwrite in client
    def possible_models
      all_possible_models
    end
    
    def load_enquiry_forms
      @@enquiry_forms = []
      form_modules = []
      Dir["#{RAILS_ROOT}/**/app/models/*_form.rb"].each do |form_file|
        form = form_file.match(/[\/](\w+)\.rb/)[1].to_s.classify.constantize
        if form.included_modules.include?(EnquiryForm)
          form_modules << form
        end
      end
      form_modules.uniq.each do |form|
        enq = Enquiry.new(:form_name => form.to_s.sub(/Form$/, '').downcase)
        @@enquiry_forms << enq
      end
    end
    
  end
  
  load_enquiry_forms
  
  def all_models?
    @models.nil? || models == self.class::all_possible_models
  end
  
  def autocomplete?
    @options[:index_prefix] == 'autocomplete'
  end
  
  def empty?(class_name = nil, options = {})
    size(class_name, options).zero?
  end
  
  def id
    object_id
  end
  
  def initialize(attrs = {}, options = {})
    attrs.symbolize_keys!    
    options.symbolize_keys!
    @options = options.reverse_merge(DEFAULT_OPTIONS).recursive_symbolize_keys!
    @conditions = (@options[:conditions] || {})
    @with = (@options[:with] || {})
    [@conditions, @with].each {|h| h.reject!{|k,v| v.blank?} }
    if Module::value_to_boolean(@options.delete(:autocomplete))
      @options[:index_prefix] = 'autocomplete'
      @options[:match_mode] = :extended
      # this is for only searching the start of words but is a bit annoying especially editing related_items
      # @term = "^#{attrs[:term]}"
      @term = attrs[:term]
    else
      @options[:match_mode] = :extended if !@options[:conditions].blank?
      #@options[:exclude_index_prefix] = 'autocomplete'
      @term = attrs[:term]
    end
    if !attrs[:models_string].blank?
      attrs[:models] ||= attrs[:models_string].split(/\s+|\s*,\s*/)
    end
    if !attrs[:models].blank?
      @models = [*attrs[:models]].reject(&:blank?).collect(&:camelize)
    end
  end
  
  def model_classes
    models.map(&:constantize)
  end

  # For some reason passing Link in classes to ThinkingSphinx means it always returns []
  def models
    default_models = self.class::possible_models
    default_models.delete("Link") if autocomplete?
    @models ||= default_models
  end
  
  # Always a new record! Needed for generating routes
  def new_record?
    true
  end
  
  def non_sphinx_results
    enquiry_form_results
  end
  
  def enquiry_form_results
    @contact_form_results ||= get_enquiry_form_results
  end
  
  def get_enquiry_form_results
    @@enquiry_forms.select {|form| form.form_title =~ /#{@term}/i}
  end
  
  def results(class_name = nil, options = {})
    return @results ||= get_results(options) if class_name.blank?
    class_name = class_name.to_s.singularize.underscore
    cached_results = instance_variable_get("@#{class_name}_results")
    return cached_results if !cached_results.nil?
    instance_variable_set("@#{class_name}_results", get_results(options.merge(:class_name => class_name.classify)))
  end
  
  def size(class_name = nil, options = {})
    return @search_count ||= get_search_count(options) if class_name.blank?
    class_name = class_name.to_s.singularize.underscore
    cached_search_count = instance_variable_get("@#{class_name}_search_count")
    return cached_search_count if !cached_search_count.nil?
    instance_variable_set("@#{class_name}_search_count", get_search_count(options.merge(:class_name => class_name.classify)))
  end

  private
  def get_search_options(options = {})
    options.reverse_merge!(@options)
    options = options.dup.to_hash.recursive_symbolize_keys!
    options[:with] = (@options[:with] || {}).dup
    class_name = options.delete(:class_name)
    if !class_name.blank?
      if class_name=="PagesSection"
        options[:classes] = [Page, Section]
      else
        options[:classes] = [class_name.constantize]
      end
    elsif !all_models? || autocomplete?
      options[:classes] = model_classes
    end
    (options[:with] || {}).each do |k, v|
      options[:with][k] = true if v == "true"
      options[:with][k] = false if v == "false"
    end
    options[:field_weights] = {:name => 10, :title => 10}
    options
  end
  
  def get_results(options = {})
    return [] if (term.blank? && @options[:conditions].blank?) || !should_search_for_class?(options[:class_name])
    ThinkingSphinx.search(term, get_search_options(options))
  end
  memoize :get_results
  
  def get_search_count(options = {})
    return 0 if (term.blank? && @options[:conditions].blank?) || !should_search_for_class?(options[:class_name])
    ThinkingSphinx.search_count(term, get_search_options(options))
  end
  
  def should_search_for_class?(class_name)
    return true if class_name.blank?
    class_name=="PagesSection" ? (models.include?("Page") || models.include?("Section")) : models.include?(class_name)
  end
  
end
