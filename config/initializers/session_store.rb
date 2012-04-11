# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => "_#{APP_CONFIG['site_name'].gsub(/\W+/, '_')}_session",
  :secret      => 'f2be9119dafc42e09d4006919c77378cb037c2a2c6868f70475801bb69f9183e5822b38a6b0b98e5b489116dbe5a873d857fdc4a656db091df2ca92a3a346396'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
ActionController::Dispatcher.middleware.use FlashSessionCookieMiddleware, ActionController::Base.session_options[:key] unless RAILS_ENV == 'cucumber'
