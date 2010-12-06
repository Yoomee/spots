run "cd #{current_path} && rake ts:stop RAILS_ENV=production -t"
run "rm -rf #{release_path}/public/uploads"
(2010..Time.now.year).each do |year|
  release_year_path = "#{release_path}/public/dragonfly/#{year}"
  shared_year_path = "#{shared_path}/dragonfly/#{year}"
  run "rm -rf #{release_year_path}" if File.exists?(release_year_path)
  run "mkdir -p #{shared_year_path}" unless File.exists?(shared_year_path)
  run "ln -nfs #{shared_year_path} #{release_year_path}"
end
run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"

run "mkdir -p #{release_path}/uploads"
(2010..Time.now.year).each do |year|
  release_year_path = "#{release_path}/uploads/#{year}"
  shared_year_path = "#{shared_path}/doc_uploads/#{year}"
  run "rm -rf #{release_year_path}" if File.exists?(release_year_path)
  run "mkdir -p #{shared_year_path}" unless File.exists?(shared_year_path)
  run "ln -nfs #{shared_year_path} #{release_year_path}"
end