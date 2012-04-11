class BackgroundRake
  
  class << self

    def call(task, options = {})
      options[:rails_env] ||= RAILS_ENV
      args = options.map {|n, v| "#{n.to_s.upcase}='#{v}'"}
      command = "rake #{task} #{args.join(' ')} --trace 2>&1 >> #{RAILS_ROOT}/log/rake.log &"
      if RAILS_ENV == 'test'
        puts "Calling: #{command}"
      else
        system command
      end
    end
   
    def method_missing(method_id, *args)
      if args.empty?
        BackgroundRake::Namespace.new(method_id)
      else
        super(method_id, *args)
      end
    end
    
  end
  
  class Namespace
    
    def call(options = {})
      BackgroundRake::call(@name, options)
    end
    
    def initialize(name)
      @name = name
    end
  
    def method_missing(method_id, *args)
      if args.empty?
        self.class::new("#{@name}:#{method_id}")
      else
        super(method_id, *args)
      end
    end
    
  end
  
end