app_config = HashWithIndifferentAccess.new(YAML.load_file("#{RAILS_ROOT}/config/settings.yml"))
app_config.merge!(app_config[RAILS_ENV]) if app_config.key?(RAILS_ENV)
client_config_file = "#{RAILS_ROOT}/client/config/settings.yml"
if File.exists?(client_config_file)
  client_config = HashWithIndifferentAccess.new(YAML.load_file("#{RAILS_ROOT}/client/config/settings.yml"))
  app_config.merge!(client_config)
  app_config.merge!(client_config[RAILS_ENV]) if app_config.key?(RAILS_ENV) && client_config.key?(RAILS_ENV)
end
APP_CONFIG = app_config