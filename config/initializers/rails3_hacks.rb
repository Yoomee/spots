# Hacks to help Rails 3 plugins work with Rails 2
class String

  def html_safe
    self
  end
  
  def html_safe?
    true
  end

end
