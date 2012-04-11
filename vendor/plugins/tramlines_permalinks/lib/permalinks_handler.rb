class PermalinksHandler

  LOG_FILE = "#{RAILS_ROOT}/log/permalinks.log"

  def initialize(app)
    @app = app
    FileUtils::touch LOG_FILE
    @logger = Logger.new(LOG_FILE)
  end

  def call(env)
    client_permalink_file = "#{RAILS_ROOT}/client/app/models/permalink.rb"
    require client_permalink_file if File.exists?(client_permalink_file)
    # Only search for permalinks when URL has the form /something (ie. only one '/')
    @logger.info("\n*********************")
    @logger.info env['PATH_INFO']
    path_info = env['ORIGINAL_PATH_INFO'] = (env['PATH_INFO'] || env['REQUEST_URI'])
    if path_info.match(/^\/[^\/]+$/)
      @logger.info "A"
      # Remove leading '/'
      path = path_info.gsub(/^\//, '')
      @logger.info("Searching for permalink #{path}...")
      if permalink = find_permalink(path)
        env_options = env.select {|k,v| %w{HTTP_HOST SERVER_NAME PATH_INFO}.include?(k)}.to_hash
        @logger.info "Using path #{permalink.model_path(env["REQUEST_METHOD"], env_options)}"
        env['REQUEST_URI'] = permalink.model_path(env["REQUEST_METHOD"], env_options)
      else
        @logger.info "No permalink found"
        env['REQUEST_URI'] = path_info
      end
    else
      env['REQUEST_URI'] = path_info
    end
    env['PATH_INFO'] = env['REQUEST_URI']
    @logger.info "env['REQUEST_URI'] = #{env['REQUEST_URI']}"
    @logger.info "env['PATH_INFO'] = #{env['PATH_INFO']}"
    @app.call(env)
  end

  private
  def find_permalink(path)
    Permalink.find_by_name(path) || OldPermalink.find_by_name(path)
  end

end
