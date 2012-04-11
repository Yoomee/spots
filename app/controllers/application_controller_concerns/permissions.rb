module ApplicationControllerConcerns
  
  module Permissions
    
    def self.included(klass)
      klass.cattr_accessor :default_permission_level
      klass.default_permission_level = :open_action
      klass.class_inheritable_accessor :ownership_model, :ownership_attribute
      klass.class_inheritable_hash :permission_levels
      klass.class_inheritable_hash :default_permission_levels
      klass.permission_levels = {}
      klass.default_permission_levels = {}
      klass.extend Classmethods
      klass.helper_method :logged_in_as_admin?
      klass.helper_method :admin_logged_in?
      klass.helper_method :logged_in?      
      klass.helper_method :logged_out?
      klass.helper_method :yoomee_staff_logged_in?
    end

    module Classmethods

      def admin_only(*actions)
        set_permission_levels(actions, :admin_only)
      end

      def admin_only_action?(action)
        permission_level(action.to_sym) == :admin_only
      end

      def allowed_to?(url_options, member)
        case
          when member_only_action?(url_options[:action])
            !member.nil?
          when admin_only_action?(url_options[:action])
            !member.nil? && member.is_admin?
          when owner_only_action?(url_options[:action])
            !member.nil? && (member.is_admin? || associated_model_instance(url_options[:id]).owned_by?(member))
          when yoomee_only_action?(url_options[:action])
            !member.nil? && member.yoomee_staff?
          when custom_permission_action?(url_options[:action])
            permission_level(url_options[:action]).call(url_options.dup, member)
          else
            true
        end
      end

      def associated_model
        ownership_model || controller_name.singularize.camelcase.constantize
      end

      def associated_model_instance(id)
        associated_model.find(associated_model_instance_id(id))
      end
      
      def associated_model_instance_id(id)
        id = id.id if !id.is_a?(Fixnum) && !id.is_a?(String)
        id.to_i
      end
      
      def custom_permission(*actions)
        set_permission_levels(actions, Proc.new)
      end

      def custom_permission_action?(action)
        permission_level(action.to_sym).is_a?(Proc)
      end

      def default_admin_only_action?(action)
        permission_level_default(action.to_sym) == :admin_only
      end
      
      def default_member_only_action?(action)
        permission_level_default(action.to_sym) == :member_only
      end
      
      def default_open_action?(action)
        permission_level_default(action.to_sym) == :open_action
      end
      
      def default_owner_only_action?(action)
        permission_level_default(action.to_sym) == :owner_only
      end
      
      def member_only(*actions)
        set_permission_levels(actions, :member_only)
      end

      def member_only_action?(action)
        permission_level(action.to_sym) == :member_only
      end
      
      def open_action(action)
        set_permission_level(action, :open_action)
        # clear_permission_levels([action])
      end
      
      def open_action?(action)
        permission_level(action.to_sym) == :open_action
        # !owner_only_action?(action) && !member_only_action?(action) && !admin_only_action?(action)
      end

      def open_actions(*actions)
        set_permission_levels(actions, :open_action)
        # clear_permission_levels(actions)
      end
      
      def owner_only(*actions)
        set_permission_levels(actions, :owner_only)
      end
            
      def owner_only_action?(action)
        permission_level(action.to_sym) == :owner_only
      end

      def permission_level(action)
        level = permission_levels[action.to_sym]
        level.nil? ? default_permission_level.to_sym : level
      end
      
      def permission_level_default(action)
        level = default_permission_levels[action.to_sym]
        level.nil? ? default_permission_level.to_sym : level
      end

      def set_default_permission_level(level)
        self.default_permission_level = level
      end

      def yoomee_only(*actions)
        set_permission_levels(actions, :yoomee_only)
      end
            
      def yoomee_only_action?(action)
        permission_level(action.to_sym) == :yoomee_only
      end

      private
      def clear_permission_levels(actions)
        actions.flatten.each do |action|
          self.permission_levels.delete(action.to_sym)
        end
      end
      
      def set_permission_level(action, level)
        level = level.to_sym if !level.is_a?(Proc)
        self.permission_levels[action.to_sym] = level
        # Set default if appropriate
        self.default_permission_levels[action.to_sym] ||= level if !level.is_a?(Proc)
      end
    
      def set_permission_levels(actions, level)
        actions.flatten.each do |action|
          set_permission_level(action, level)
        end
      end

    end
    
    def admin_logged_in?
      @logged_in_member && @logged_in_member.is_admin?
    end
    alias_method :logged_in_as_admin?, :admin_logged_in?
    
    def admin_only_action?(action)
      self.class::admin_only_action?(action)
    end

    def allowed_to?(url_options, member)
      self.class::allowed_to?(url_options, member)
    end
    
    def default_admin_only_action?(action)
      self.class::default_admin_only_action?(action)
    end

    def default_member_only_action?(action)
      self.class::default_member_only_action?(action)
    end
    
    def default_open_action?(action)
      self.class::default_open_action?(action)
    end

    def default_owner_only_action?(action)
      self.class::default_owner_only_action?(action)
    end

    def logged_in?
      !@logged_in_member.nil?
    end

    def logged_out?
      @logged_in_member.nil?
    end

    def member_only_action?(action)
      self.class::member_only_action?(action)
    end

    def open_action?(action)
      self.class::open_action?(action)
    end

    def owner_only_action?(action)
      self.class::owner_only_action?(action)
    end
    
    def yoomee_only_action?(action)
      self.class::yoomee_only_action?(action)
    end
    
    def yoomee_staff_logged_in?
      @logged_in_member && @logged_in_member.yoomee_staff?
    end

  end
  
end
