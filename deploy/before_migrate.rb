# Workling
# # Stop old workling client if exists
# run "cd #{current_path} && sudo RAILS_ENV=#{environment} script/workling_client stop" 
# # Start starling
# run "cd #{release_path} && sudo starling -d -p 15151"

run "cd #{release_path} && sudo ext up"
run "sudo touch #{shared_path}/log/#{environment}.log"
run "sudo chown deploy:deploy #{shared_path}/log/#{environment}.log"
run "cd #{release_path} && sudo rake gems:install RAILS_ENV=#{environment} -t"

db_yaml_path = "#{shared_path}/config/database.yml"
db_yaml = YAML.load_file(db_yaml_path)
db_yaml[environment]['reconnect'] = true
File.open(db_yaml_path, 'w') do |file|
  file.puts YAML::dump(db_yaml)
end