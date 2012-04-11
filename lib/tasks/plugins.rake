Dir["#{File.dirname(__FILE__)}/../../vendor/plugins/tramlines_*/lib/tasks.rake"].each do |path|
  load path
end