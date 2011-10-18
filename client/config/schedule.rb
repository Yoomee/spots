every 1.day, :at => '4pm' do
  set :output, File.expand_path("#{File.dirname(__FILE__)}/../../../shared/sphinx_rebuilds.log")
  rake "ts:index -t"
end
