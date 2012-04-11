module EnquiryForm
  
  def self.included(klass)
    klass.extend(ClassMethods)
    klass.extend(Forwardable)
    klass.metaclass.class_eval do

      attr_accessor :mandatory_fields, :format_fields
      def validates_presence_of(*args)
        self.mandatory_fields ||= []
        self.mandatory_fields += [*args].map(&:to_sym)
      end
      
      def validates_format_of(*attr_names)
        options = attr_names.extract_options!.reverse_merge({:message => 'is invalid'})
        self.format_fields ||= {}
        attr_names.each do |attr_name|
          format_fields[attr_name] = options
        end
      end

      private
      def define_field(enquiry, field)
        if enquiry.respond_to?(field)
          # Method already exists
          raise NameError.new("#{field} is not allowed as a field name - #{enquiry} already has a #{field} method")
        else
          # Add getter
          enquiry.metaclass.send(:define_method, field) do
            enquiry_fields.detect {|ef| ef.name.to_s == field.to_s}.try(:value)
          end
          # Add setter
          enquiry.metaclass.send(:define_method, "#{field}=") do |value|
            enquiry_field = enquiry_fields.detect {|ef| ef.name == field.to_s} || enquiry_fields.build(:name => field.to_s)
            enquiry_field.value = value
          end
        end
      end

      # This method gets called when the enquiry object extends the appropriate form
      define_method(:extended) do |enquiry|
        #enquiry.extend(ActiveRecordExtensions::ValidationReflection)
        
        # Create getters and setters for the fields of the form 
        enquiry.fields.each do |field|
          define_field(enquiry, field)
        end
        (mandatory_fields || []).each do |field|
          enquiry.metaclass.send(:define_method, "validate_with_#{field}_mandatory") do
            send("validate_without_#{field}_mandatory")
            errors.add_on_blank(field)
          end
          enquiry.metaclass.alias_method_chain :validate, "#{field}_mandatory"
        
          # Adda <field>_required? method for all mandatory fields
          enquiry.metaclass.send(:define_method, "#{field}_required?") do
            true
          end
        end
        
        (format_fields || {}).each do |field, options|
          enquiry.metaclass.send(:define_method, "validate_with_#{field}_format") do
            send("validate_without_#{field}_format")
            if (send(field).blank? && !options[:allow_blank]) || (!send(field).blank? && !send(field).match(options[:with]))
              errors.add(field, options[:message])
            end
          end
          enquiry.metaclass.alias_method_chain :validate, "#{field}_format"
        end
              
      end
    end
  end
  
  module ClassMethods

    # These declaration methods and (validates_presence_of etc.) should provide all the configuration for a form module
    # Eg.
    # module GubbinsForm
    #  include EnquiryForm
    #  <...configure away...>
    # end

    def email_from(email)
      define_method(:email_from) {email}
    end
    
    def email_subject(subject)
      define_method(:email_subject) {subject}
    end
    
    def email_to(email)
      define_method(:email_to) {email}
    end
    
    def fields(*args)
      define_method(:fields) {[*args]}
    end
    
    def response_message(msg)
      define_method(:response_message) {msg}
    end
    
    def title(title)
      define_method(:form_title) {title}
    end
    
  end
  
end

class Formtastic::SemanticFormBuilder
  
  def method_required_with_enquiry_form?(attribute)
    required_method = "#{attribute}_required?"
    if @object && @object.respond_to?(required_method)
      @object.send(required_method) || method_required_without_enquiry_form?(attribute)
    else
      method_required_without_enquiry_form?(attribute)
    end
  end
  alias_method_chain(:method_required?, :enquiry_form)
  
end
