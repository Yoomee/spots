# Include hook code here
ActiveRecord::Base.class_eval do
  
  class << self
    
    # Takes a class as it's wall class
    def has_wall
      include ::TramlinesWalls::HasWall
    end
    
  end
  
  def has_wall?
    self.is_a?(WallPost) ? false : respond_to?(:wall)
  end
  
end

%w(controllers helpers models views).each {|path| ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'app', path) }
ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'lib')