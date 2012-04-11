# Disable wrapping in a closure, so that we can reference initialized variables elsewhere
Barista.bare!

Barista::Framework.class_eval do
  
  def coffeescript_glob_path
    @coffeescript_glob_path ||= "#{RAILS_ROOT}/app/coffeescripts/**{,/*/**}/*.coffee"
  end
  
end