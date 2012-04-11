class AdminLink

  attr_reader :name, :url
  
  PLURAL_ACTIONS = %w{list}
  ROOT_CONTROLLER_PATHS = %W{#{RAILS_ROOT}/app/controllers #{RAILS_ROOT}/client/app/controllers}
  
  def initialize(name, url, controller)
    case url
      when Symbol
        @url = url_for_action(url, controller)
        @name = name || name_for_action(url, controller)
      else
        @url = url
        @name = name
    end
  end
  
  def <=>(other_item)
   name <=> other_item.name
  end

  private
  def name_for_action(action, controller)
   action = action.to_s
   action = 'list' if action == 'index'
   if action.in?(PLURAL_ACTIONS)
     "#{action.titleize} #{controller.controller_name.to_s.titleize.downcase}"
   else
     "#{action.titleize} #{controller.controller_name.singularize.to_s.titleize.downcase}"
   end
  end
 
  def url_for_action(action, controller)
    {:controller => controller.controller_name, :action => action}
  end
  
end
