# This should just be the same as production
production_path = "#{RAILS_ROOT}/config/environments/production.rb"
eval(IO.read(production_path), binding, production_path)