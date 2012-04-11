gem 'sinatra', '1.0'
require 'sinatra/base'
require 'resque/server'

Resque::Server.class_eval do
  
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == ['resque', 'drumkitballoonpostit']
  end
  
end

class ResqueWeb < Sinatra::Base
  
  def call(env)
    if env["PATH_INFO"] =~ /^\/resque/
      env["PATH_INFO"].sub!(/^\/resque/, '')
      env['SCRIPT_NAME'] = '/resque'
      app = Resque::Server.new
      app.call(env)
    else
      super
    end
  end
  
end