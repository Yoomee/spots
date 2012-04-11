module TramlinesPermalinks

  def self.included(klass)
    ApplicationController.send(:include, ApplicationControllerConcerns::Permalinks)
  end
  
end
