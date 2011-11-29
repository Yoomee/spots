every 1.day, :at => '3pm' do
  set :output, File.expand_path("#{File.dirname(__FILE__)}/../../../shared/sphinx_rebuilds.log")
  rake "ts:index -t"
end

every 1.day, :at => '12am' do
  rake "spots:daily -t"
end

every 7.days, :at => '12am' do
  rake "spots:weekly -t"
end