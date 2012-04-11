require 'forwardable'
class Report
  
  attr_accessor :view

  
  DEFAULTS = {:view => 'html'}
  
  def initialize(attrs = {})
    (attrs || {}).reverse_merge(DEFAULTS).each do |k, v|
      send("#{k}=", v)
    end
  end
 
  def name
    self.class.to_s.sub(/Report$/, '').underscore
  end
  
  class_inheritable_accessor :field_names
  class_inheritable_accessor :headings

  class << self
    
    def fields(*fields)
      self.field_names = []
      self.headings = []
      fields.each do |field|
        if field.is_a?(Array)
          self.field_names << field[0]
          headings << field[1]
        else
          self.field_names << field
          headings << field.to_s.titleize
        end
      end
    end
   
    def preset_params(*attr_names)
      define_method(:preset_param_names) {attr_names.map(&:to_s)}
    end

    def title(title)
      define_method(:title) {title}
    end
 
  end
 
  def preset_param_names
    []
  end
 
  def rows
    []
  end
 
  class Row

    extend Forwardable

    class << self

      # Utility method to delegate all fields to an object
      def delegate_all_to(obj)
        def_delegators obj, *parent::field_names
      end

      def field_names
        parent.field_names
      end

    end

    def field_names
      self.class.field_names
    end

    def values
      field_names.map do |field|
        raw = send(field)
        case raw
          when Time
            raw.to_s(:short_date_and_time)
          else
            raw
        end
      end
    end
 
  end
end
