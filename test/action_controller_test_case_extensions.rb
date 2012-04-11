class ActionController::TestCase
  
  class << self
    
    def context_unless_plugin(plugin_name, context_name, &block)
      unless File.exists?("#{RAILS_ROOT}/vendor/plugins/#{plugin_name}")
        context(context_name, &block)
      end
    end

  end
  
  def expect_admin
    expect_logged_in_member(:admin_member)
  end
  
  def expect_logged_in_member(factory = :member, attributes = {})
    attributes.reverse_merge!({:id => 1})
    logged_in_member = Factory.build(factory, attributes)
    @controller.expects(:find_logged_in_member).returns logged_in_member
    logged_in_member
  end

  def create_logged_in_member(factory = :member, attributes = {})
    attributes.reverse_merge({:id => 1})
    logged_in_member = Factory.create(factory, attributes)
    @controller.expects(:find_logged_in_member).returns logged_in_member
    logged_in_member
  end

  # used if the action has no permission level set, so depending on default_permission_level, might be open or member_only
  def might_expect_logged_in_member(factory = :member, attributes = {})
    if ApplicationController.default_permission_level != :open_action
      expect_logged_in_member(factory, attributes)
    end
  end
  
  def stub_access
    @controller.stubs(:gate_keep).returns true
  end

  # Pass in a symbol if the model is in a plugin
  def stub_finds(model_class, factory_object = nil)
    if model_class.class.in?([String, Symbol])
      begin
        model_class = model_class.to_s.constantize
      rescue NameError
        # No such class in this project
        return
      end
    end
    factory_object ||= Factory.build(model_class.to_s.underscore)
    factory_object = factory_object.call if factory_object.is_a?(Proc)
    model_class.stubs(:find).returns factory_object
    model_class.stubs(:find).with {|*args| args.first == :all}.returns [factory_object]
  end
  
end
