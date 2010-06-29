HomeController.class_eval do
  
  before_filter :get_events, :only => :index
  
  private
  def get_events
    @events = Event.closest.limit(3)
  end
  
end