
module ActiveRecord

  class Base

    def self.random_record
      if (c = count) != 0
        find(:first, :offset =>rand(c))
      end
    end

    def concat_fields fields, sep = ", ", ignore_blank = false
      str = fields.map {|field_name| send field_name}
      str = str.reject {|field_value| field_value.blank? } if ignore_blank
      str.join(sep)
    end
    
    def to_s_with_name
      default = to_s_without_name
      if default.match(/^#<#{self.class.to_s}.*>$/) && respond_to?(:name)
        name
      else
        default
      end
    end
    alias_method_chain :to_s, :name

  end

end

class ActiveRecord::Base

  include ValidateExtensions

  named_scope :latest, :order => "created_at DESC, id DESC"
  named_scope :limit, lambda{|limit| {:limit => limit}}
  named_scope :not_including, lambda {|klass_instance| {:conditions => (klass_instance.nil? || klass_instance.new_record?) ? "" : ["#{klass_instance.class.table_name}.id != ?", klass_instance.try(:id)]}}
  named_scope :oldest, :order => "created_at ASC"
  named_scope :random, :order => "RAND()"
  named_scope :scope_for_group_by_id, lambda {|table_name| {:group => "#{table_name}.id"}}
  named_scope :scope_for_with_id_in, lambda {|table_name, ids| {:conditions => ["#{table_name}.id IN (?)", ids]}}
  named_scope :scope_for_without_id_in, lambda {|table_name, ids| {:conditions => ["#{table_name}.id NOT IN (?)", ids]}}
  named_scope :scoped_all, :conditions => {}
  named_scope :attachable_is, lambda {|attachable| {:conditions => {:attachable_type => attachable.class.to_s, :attachable_id => attachable.id}}}

  class << self

    def alias_scope(new_scope, old_scope)
      metaclass.send(:define_method, new_scope) {send(old_scope)}
    end

    def add_to_news_feed(options = {})
      include AddToNewsFeed unless included_modules.include?(AddToNewsFeed)
      options.reverse_merge!(:on_create => true, :on_update => false)
      self.news_feed_actions = options[:only] || []
      self.news_feed_actions << "create" if options[:on_create]
      self.news_feed_actions << "update" if options[:on_update] || !options[:on_attributes].blank?
      self.on_news_feed_attributes = options[:on_attributes] || []
      self.except_news_feed_attributes = options[:except_attributes] || []
      self.news_feed_weighting = options[:weighting] || 1
      self.group_news_feed_item_within = options[:group_items_within] || 0.seconds
    end
    
    def has_multiple_form_steps
      attr_writer :form_step
      define_method(:form_step) do
        @form_step || 1
      end
      define_method(:next_form_step!) do
        self.form_step = form_step.to_i + 1
      end
      define_method(:on_form_step?) do |num|
        self.form_step.to_i == num
      end
    end

    def find_by_id_or_instance(id_or_instance, options = {})
      if id_or_instance.is_a?(self)
        id_or_instance
      else
        find_by_id(id_or_instance, options)
      end
    end

    def formatted_date_accessor(*names)
      names.each do |name|
        validates_date_format_of("formatted_#{name}", :allow_blank => true)
        define_method("formatted_#{name}") do
          unsaved_date = instance_variable_get("@formatted_#{name}")
          return unsaved_date unless unsaved_date.blank?
          self[name].blank? ? self[name] : self[name].strftime('%d/%m/%Y')
        end
        define_method("formatted_#{name}=") do |value|
          self[name] = value.blank? ? nil : Date.parse(value.gsub('/', '-'))
          instance_variable_set("@formatted_#{name}", value)
        end
      end
    end

    def formatted_time_accessor(*names)
      names.each do |name|
        validates_time_format_of("formatted_#{name}", :allow_blank => true)
        define_method("formatted_#{name}") do
          unsaved_date = instance_variable_get("@formatted_#{name}")
          return unsaved_date unless unsaved_date.blank?
          self[name].nil? ? nil : self[name].in_time_zone.strftime('%d/%m/%Y %H:%M')
        end
        define_method("formatted_#{name}=") do |value|
          # datetime = DateTime.strptime(value, '%d/%m/%Y %H:%M').to_time
          self[name] = value.blank? ? nil : Time.zone.parse(value.gsub('/', '-'))
          instance_variable_set("@formatted_#{name}", value)
        end
      end
    end

    def group_by_id
      scope_for_group_by_id(table_name)
    end

    def has_breadcrumb_parent(method_name)
      alias_method "breadcrumb_parent", method_name
      define_method("breadcrumb") do
        if !breadcrumb_parent.nil? && breadcrumb_parent.respond_to?(:breadcrumb)
          return breadcrumb_parent.breadcrumb << self
        else
          return [self]
        end
      end
    end

    def has_virtual_attributes(*names)
      names.each do |name|
        define_method("attributes_with_#{name}") do
          returning out = send("attributes_without_#{name}") do
            out[name.to_s] = send(name)
          end
        end
        alias_method_chain :attributes, name
      end
    end
    alias_method :has_virtual_attribute, :has_virtual_attributes

    def is_rateable?
      included_modules.any? {|mod| mod.to_s == 'TramlinesRatings::RateableByMember'}
    end

    def search_attributes(attributes, options = {})
      attributes = [*attributes]
      options.reverse_merge!(:delta => true, :autocomplete => true, :where => "")
      has_attributes = [*options[:has]].compact
      define_index do
        attributes.each {|a| indexes a}
        has_attributes.each {|a| has a}
        has attributes.first, :as => :to_s, :type => :string
        #where options[:where]
        set_property :delta => options[:delta]
      end
      if options[:autocomplete]
        autocomplete_attributes = options[:autocomplete].is_a?(Array) ? options[:autocomplete] : [attributes.first]
        define_index("autocomplete_#{self.to_s.downcase}") do
          autocomplete_attributes.each {|a| indexes a}
          has_attributes.each {|a| has a}
          has attributes.first, :as => :to_s, :type => :string          
          #where options[:where]          
          set_property :delta => options[:delta]
        end
      end
      
      # The summary fields default to being the search_attributes with the first excluded - if something different is required, it can be overwritten in the model
      define_method(:summary_fields) do
        attributes - [attributes.first]
      end
    end

    def site_uses_fb_connect?
      ApplicationController.new.site_uses_fb_connect?
    end

    def to_s_for_search
      to_s.pluralize
    end

    def with_id_in(ids)
      scope_for_with_id_in(table_name, ids)
    end
    
    def without_id_in(ids)
      ids.blank? ? scoped_all : scope_for_without_id_in(table_name, ids)
    end

  end

  def concat_fields fields, sep = ", ", ignore_blank = false
    str = fields.map {|field_name| send field_name}
    str = str.reject {|field_value| field_value.blank? } if ignore_blank
    str.join(sep)
  end
  
  # clears errors and all associations' errors
  def clear_all_errors
    errors.each do |attribute, m|
      if res = attribute.match(/^([^\.]+)\.(.+)/)
        assoc_instance = send(res[1])
        if assoc_instance.is_a?(Array)
          assoc_instance.each(&:clear_all_errors)
        else
          assoc_instance.clear_all_errors if assoc_instance.respond_to?(:clear_all_errors)
        end
      end
    end
    errors.clear
  end
  
  # checks if specific fields are valid, generating errors for only those fields
  def fields_valid?(*fields)
    fields = [*fields].flatten.map{|f| f.to_s.gsub(/\(.*\)$/, "").gsub(/\[\]$/, "")}.uniq
    valid?
    all_errors = errors.dup
    clear_all_errors # including associations' errors
    association_errors_blank = true
    # put relevant errors back in
    all_errors.each do |attribute, msg|
      # check for association errors, in the form "contact.forename" or has_many, "contacts.forename"
      if res = attribute.match(/^([^\.]+)\.(.+)/)
        assoc_name = res[1]
        if assoc_name.in?(fields)
          association_errors_blank = false
          assoc_instance = send(assoc_name)
          assoc_instance.is_a?(Array) ? assoc_instance.each(&:valid?) : assoc_instance.valid?
        end
      else
        errors.add(attribute, msg) if attribute.in?(fields)
      end
    end
    errors.blank? && association_errors_blank
  end
  
  def has_image?(image_attr = 'image_uid')
    # return false if self.class::included_modules.include?(TramlinesImages)
    image_attr = image_attr.to_s
    image_attr = "#{image_attr}_uid" unless image_attr.match(/_uid$/)
    !read_attribute(image_attr).blank?
  end

  def has_news_feed_item?
    return false unless respond_to?(:news_feed_item)
    !news_feed_item.nil?
  end

  def is_media?
    self.class.included_modules.include?(Media)
  end

  def is_rateable?
    self.class::is_rateable?
  end

  def non_blank_attributes
    attributes.reject {|k, v| v.blank?}
  end

  def owned_by?(member)
    return (self == member) if self.is_a?(Member)
    return false if !respond_to?(:member)
    self.member == member
  end

end

class ActiveRecord::Errors

  # Make validates_presence_of work with HTML
  def add_on_blank(attributes, custom_message = nil)
    for attr in [attributes].flatten
      value = (@base.respond_to?(attr.to_s) ? @base.send(attr.to_s) : @base[attr.to_s])
      if value.is_a?(String)
        value = value.dup
        # Remove brs
        value.gsub!(/<br\s?\/>/, '')
        # Remove empty p tags
        value.gsub!(/<p>\s*<\/p>/, '')
      end
      add(attr, :blank, :default => custom_message) if value.blank?
    end
  end
  
  def fields
    returning out = [] do
      each do |attr, val|
        out << attr unless out.include?(attr)
      end
    end
  end

  def to_message
    full_arr = []
    each_full do |msg|
      full_arr << msg
    end
    full_arr.join(', ')
  end

end

class ActiveRecord::Migration

  class_inheritable_accessor :filename

  class << self

    def announce(message)
      text = "#{@version} #{name} (#{filename.try(:gsub, /^#{RAILS_ROOT}\//, '')}): #{message}"
      length = [0, 75 - text.length].max
      write "== %s %s" % [text, "=" * length]
    end

  end

end

class ActiveRecord::MigrationProxy

  private
    def load_migration_with_filename_setting
      returning out = load_migration_without_filename_setting do
        out.filename = filename
      end
    end
    alias_method_chain :load_migration, :filename_setting

end

class ActiveRecord::Migrator

  def migrations_with_tramlines_paths
    @migrations_with_tramlines_paths ||= begin
      migrations = tramlines_migrations_paths.inject([]) do |memo, path|
        @migrations = nil
        @migrations_path = path
        memo + migrations_without_tramlines_paths
      end
      migrations = migrations.sort_by(&:version)
      down? ? migrations.reverse : migrations
    end
  end
  alias_method_chain :migrations, :tramlines_paths

  def tramlines_migrations_paths
    @tramlines_migrations_paths ||= ["#{RAILS_ROOT}/db/migrate", "#{RAILS_ROOT}/client/db/migrate"] + tramlines_plugin_migrations_paths
  end

  def tramlines_plugin_migrations_paths
    Dir["#{RAILS_ROOT}/vendor/plugins/tramlines_*/db/migrate"]
  end

end

# Fix for destroying new records which use thinking sphinx
module ThinkingSphinx::ActiveRecord

  def sphinx_document_id_with_destroy_fix
    new_record? ? 0 : sphinx_document_id_without_destroy_fix
  end
  alias_method_chain :sphinx_document_id, :destroy_fix

end

ActiveRecord::Associations::BelongsToPolymorphicAssociation.class_eval do

  def association_class
    @owner[@reflection.options[:foreign_type]].present? ? @owner[@reflection.options[:foreign_type]].constantize : nil
  end

  def replace(record)
    if record.blank?
      @target = @owner[@reflection.primary_key_name] = @owner[@reflection.options[:foreign_type]] = nil
    else
      @target = (ActiveRecord::Associations::AssociationProxy === record ? record.target : record)

      @owner[@reflection.primary_key_name] = record_id(record)
      @owner[@reflection.options[:foreign_type]] = record.class.base_class.name.to_s

      @updated = true
    end

    loaded
    record
  end

end

# Needed to allow overwriting search_attributes
CUSTOMIZED_MEMBER_INDEXES = false