# TramlinesWalls
module TramlinesWalls

  def self.included(klass)
    Member.send(:include, TramlinesWalls::MemberExtensions)
  end
  
  module HasWall
    
    def self.included(klass)
      #the class's wall class is set by the ActiveRecord::Base has_wall method
      # klass.has_one :wall, :class_name => klass.wall_class.to_s, :dependent => :destroy
      klass.has_one :wall, :as => :attachable, :dependent => :destroy
      klass.has_many :wall_posts, :through => :wall
      # Make wall inititialize on first call
      klass.send(:define_method, :wall_with_self_instantiation) do
        @wall ||= (wall_without_self_instantiation || create_wall)
      end
      klass.alias_method_chain :wall, :self_instantiation
      # klass.delegate :wall_posts, :to => :wall
      #klass.delegate :has_comments?, :to => :wall
      klass.extend Forwardable
      klass.def_delegator :wall, :has_comments?
      klass.def_delegator :wall, :has_posts?
      klass.send(:alias_method, :comments, :wall_posts)
    end
    
  end
  
end