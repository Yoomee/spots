module ProvidesAdminItems
  
  def self.included(klass)
    klass.extend ClassMethods
  end
  
  module ClassMethods
    
    @@admin_links = []
    
    def admin_link(tab_name, action_or_hash, link_name = nil)
      tab = AdminTab::register(tab_name.to_s)
      tab.links << AdminLink.new(link_name, action_or_hash, self)
    end
    
  end
  
  
end
