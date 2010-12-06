run "cd #{release_path} && sudo ext update"
run "sudo touch #{shared_path}/log/production.log"
run "sudo chown deploy:deploy #{shared_path}/log/production.log"
run "cd #{release_path} && sudo rake gems:install RAILS_ENV=production -t"

db_yaml_path = "#{shared_path}/config/database.yml"
db_yaml = YAML.load_file(db_yaml_path)
db_yaml['production']['reconnect'] = true
File.open(db_yaml_path, 'w') do |file|
  file.puts YAML::dump(db_yaml)
end

# Stop old workling client if exists
run "cd #{current_path} && sudo RAILS_ENV=production script/workling_client stop" if File.exists?("#{current_path}/log/workling.pid")
# Start starling
run "cd #{release_path} && sudo starling -d -p 15151"
# Start new workling client
run "cd #{release_path} && sudo RAILS_ENV=production script/workling_client start"