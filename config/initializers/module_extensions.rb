class Module

  TRUE_VALUES	=	[true, 1, '1', 't', 'T', 'true', 'TRUE'].to_set
  
  def attr_boolean_accessor(*attrs)
    attr_boolean_writer(*attrs)
    attr_accessor(*attrs)
    attrs.each do |attr|
      define_method(attr) do
        Module::value_to_boolean(instance_variable_get("@#{attr}"))
      end
      alias_method "#{attr}?", attr
    end
  end
  
  def attr_boolean_writer(*attrs)
    attrs.each do |attr|
      attr = attr.to_s
      define_method "#{attr}=" do |val|
        instance_variable_set("@#{attr}", Module::value_to_boolean(val))
      end
    end
  end

  def value_to_boolean(value)
    if value.is_a?(String) && value.blank?
      false
    else
      TRUE_VALUES.include?(value)
    end
  end
  
end