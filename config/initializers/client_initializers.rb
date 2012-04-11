Dir["#{RAILS_ROOT}/client/config/initializers/*.rb"].each do |initializer| 
  require initializer
end
