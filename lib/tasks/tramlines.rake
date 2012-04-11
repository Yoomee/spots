require 'find'

namespace :tramlines do

  task :test do
    errors = %w(tramlines:test:core tramlines:test:client tramlines:test:plugins).collect do |task|
      begin
        Rake::Task[task].invoke
        nil
      rescue => e
        task
      end
    end.compact
    abort "Errors running #{errors.to_sentence(:locale => :en)}!" if errors.any?
  end

  namespace :test do

    Rake::TestTask.new(:core => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = 'test/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:core'].comment = "Run the Tramlines core tests"

    Rake::TestTask.new(:client => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = 'client/test/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:core'].comment = "Run the Tramlines client tests"
    
    Rake::TestTask.new(:plugins => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = 'vendor/plugins/tramlines_*/test/**/*_test.rb'
      t.verbose = true
    end
    Rake::Task['test:core'].comment = "Run the Tramlines plugin tests"
    
  end
    
end

Rake::TaskManager.class_eval do
  
  def remove_task(task_name)
    @tasks.delete(task_name.to_s)
  end
  
end

def remove_task(task_name)
  Rake.application.remove_task(task_name)
end

namespace :db do
  
  remove_task "db:seed"
  desc 'Load the seed data from db/seeds.rb and client/db/seeds.rb'
  task :seed => :environment do
    seed_files = [File.join(Rails.root, 'db', 'seeds.rb'), File.join(Rails.root, 'client', 'db', 'seeds.rb')]
    seed_files.each do |seed_file|
      load(seed_file) if File.exist?(seed_file)
    end
  end
  
  desc 'Dump database'
  task :dump do
    config = YAML.load(File.new(File.join(RAILS_ROOT, '/config/database.yml')))
    if config.keys.count == 1
      config = config[config.keys.first]
    else
      config = config[RAILS_ENV]
    end
    db = config["database"]
    dump_path = "#{RAILS_ROOT}/db/#{db}.sql"
    puts "Dumping #{db} database to #{dump_path}"
    system("mysqldump -u#{config["username"]} -p#{config["password"]} #{db} > #{dump_path}")
    puts "Compressing #{db}.sql to #{db}.sql.tgz"
    system("cd #{RAILS_ROOT}/db && tar -czvf #{db}.sql.tgz #{db}.sql")
    puts "Complete"
  end
  
  namespace :test do
    desc 'Create the test database defined in config/database.yml'
    task :create => :load_config do
      create_database(ActiveRecord::Base.configurations["test"])
    end
  end
  
  desc "Migrate and prepare test database"
  task :full_migrate => [:migrate, 'test:prepare']
  
  desc "Alias of full_migrate"
  task :migrate_full => :full_migrate
  
  namespace :migrate_full do
    
    desc "Rollbacks the database one migration and re migrate up. Then prepares the test database"
    task :redo => ["migrate:redo", "test:prepare"]
    
  end
  
end
  