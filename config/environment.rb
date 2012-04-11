# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %W(#{RAILS_ROOT}/client/app/controllers #{RAILS_ROOT}/client/lib #{RAILS_ROOT}/client/app/models #{RAILS_ROOT}/client/app/helpers #{RAILS_ROOT}/client/app/workers #{RAILS_ROOT}/client/app/sweepers #{RAILS_ROOT}/app/workers)

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  config.gem 'fastercsv'
  config.gem 'httparty'
  # config.gem 'dragonfly', :version => "0.6.2"
  config.gem 'dragonfly', '0.8.2'
  config.gem 'rack-cache', :lib => 'rack/cache'  
  config.gem 'aasm', :source => 'http://gemcutter.org', :version => '2.3.1'
  config.gem 'formtastic', :source => 'http://gemcutter.org', :version => '1.0.1'
  config.gem "acts-as-taggable-on", :source => "http://gemcutter.org", :version => '2.0.6'
  config.gem 'will_paginate', :version => "~> 2.3"  
  config.gem 'haml', :version => '3.0.25'
  config.gem 'hpricot'
  config.gem 'json'
  config.gem 'has_many_polymorphs'
  config.gem 'SystemTimer', :lib => 'system_timer', :source => "http://gemcutter.org/" 
  # config.gem 'system_timer' # for memcache-client
  config.gem 'eventmachine' # for memcache-client
  config.gem 'memcache-client', :lib => 'memcache' # for starling  
  config.gem 'starling-starling', :source => "http://gems.github.com/", :lib => 'starling'
  config.gem 'daemons' #for workling
  # config.gem 'validatable'
  #config.gem 'jnunemaker-validatable', :lib => "validatable",:source => 'http://gemcutter.org'
  config.gem 'responds_to_parent'
  config.gem 'geokit'
  config.gem 'thinking-sphinx', :lib => 'thinking_sphinx', :version => '1.3.20'
  config.gem 'will_paginate'
  config.gem 'simplificator-rwebthumb', :lib => 'rwebthumb'
  config.gem 'datetimespan'
  config.gem 'whenever'
  config.gem 'yoomee-decent_exposure', :lib => 'decent_exposure', :version => '1.2.1'
  config.gem 'barista'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  config.plugins = [:all, :tramlines_ckeditor]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.active_record.default_timezone = :utc
  config.time_zone = 'London'
  
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  
  client_environment = "#{RAILS_ROOT}/client/config/environment.rb"
  client_rails_env_environment = "#{RAILS_ROOT}/client/config/environments/#{RAILS_ENV}.rb"
  require client_environment if File.exists?(client_environment)
  require client_rails_env_environment if File.exists?(client_rails_env_environment)
  begin
    ClientEnvironment.setup(config) if ClientEnvironment.respond_to?(:setup)
    ClientEnvironment.send("setup_#{RAILS_ENV}", config)
  rescue NameError
    # ClientEnvironment doesn't exist
  end

  if defined?(PhusionPassenger)
    PhusionPassenger.on_event(:starting_worker_process) do |forked|
      if forked
        # Rails cache_store
        Rails.cache.instance_variable_get(:@data).reset if Rails.cache.to_s.match(/(ActiveSupport::Cache::MemCacheStore|MemCacheStoreWithDeleteMatched)/)

        # Reset the session_store, value could be nil depending on how you set it up
        ActionController::Base.session_options[:cache].try(:reset)
      end
    end
  end
  
end

# client_helpers_dir_glob = "#{RAILS_ROOT}/client/app/helpers"

#ApplicationController.send(:helper, :all)

