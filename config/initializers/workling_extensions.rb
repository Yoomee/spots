Workling.load_path.unshift("#{RAILS_ROOT}/client/app/workers")
if APP_CONFIG[:use_workling?]
  begin
    Workling::Return::Store.instance = Workling::Return::Store::StarlingReturnStore.new 
  rescue Exception => e
    if RAILS_ENV =~ /development|test/
      puts "\e[31m=> WARNING: Workling not started.\e[0m"
    else
      raise e
    end
  end
end
