if !$rails_rake_task && !ARGV.include?("no-boost") && ($0 != "irb") && (Rails.env.development? || (config.respond_to?(:soft_reload) && config.soft_reload))
  puts("=> Rails Dev Boost ON")
  require 'rails_development_boost'
  RailsDevelopmentBoost.apply!
else
  puts("=> Rails Dev Boost OFF")
end
