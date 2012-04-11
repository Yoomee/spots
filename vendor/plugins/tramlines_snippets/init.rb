# Include hook code here

class ActiveRecord::Base
   
  class << self

    def has_snippets
      send(:include, HasSnippets)
    end

  end
  
end