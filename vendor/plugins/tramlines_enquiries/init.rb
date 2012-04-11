%w(controllers helpers models views).each do |path|
  ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'app', path)
end
ActiveSupport::Dependencies.load_once_paths.delete File.join(File.dirname(__FILE__), 'lib')