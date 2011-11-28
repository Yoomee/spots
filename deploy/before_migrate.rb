run "cd #{release_path} && sudo ext up"
run "sudo touch #{shared_path}/log/production.log"
run "sudo chown deploy:deploy #{shared_path}/log/production.log"
run "cd #{release_path} && sudo rake gems:install RAILS_ENV=production -t"

db_yaml_path = "#{shared_path}/config/database.yml"
db_yaml = YAML.load_file(db_yaml_path)
db_yaml['production']['reconnect'] = true
File.open(db_yaml_path, 'w') do |file|
  file.puts YAML::dump(db_yaml)
end
