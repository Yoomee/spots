class AdminTab

  @@admin_tabs = []
  @@loaded = false
  @@order = []  
  
  attr_reader :name
  
  class << self
    
    def all
      load if !@@loaded
      @@admin_tabs
    end
    
    def find(name)
      load if !@@loaded
      find_loaded(name)
    end
    
    def register(name)
      unless tab = find_loaded(name)
        tab = new(name)
        @@admin_tabs << tab
        @@admin_tabs.sort!
      end
      tab
    end
    
    def set_order(order)
      @@order = order
    end
    
    private
    def find_loaded(name)
      @@admin_tabs.detect {|tab| tab.name == name}
    end
    
    def load
      ActionController::Routing::possible_controllers.each do |controller|
        "#{controller.camelcase}Controller".constantize
      end
      @@loaded = true
    end
    
  end
  
  def <=>(other_tab)
    if order_key && other_order_key = other_tab.order_key
      order_key <=> other_order_key
    else
      name <=> other_tab.name
    end
  end

  def initialize(name)
    @name = name
    @links = []
  end

  def links
    @links.sort!
  end

  def order_key
    order_stringified.index(name.to_s)
  end

  private
  def order_stringified
    @@order.map(&:to_s)
  end
  
end

