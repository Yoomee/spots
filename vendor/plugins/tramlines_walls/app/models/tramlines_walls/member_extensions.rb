module TramlinesWalls::MemberExtensions
  
  def self.included(klass)
    klass.has_many :written_wall_posts, :class_name => "WallPost", :dependent => :destroy
  end
  
end