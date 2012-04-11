module TramlinesBlog
  
  def self.included(klass)
    Member.send(:include, TramlinesBlog::MemberExtensions)
  end
  
end
