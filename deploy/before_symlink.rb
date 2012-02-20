run "rm -rf #{release_path}/public/uploads"
(2010..Time.now.year+5).each do |year|
  release_year_path = "#{release_path}/public/dragonfly/#{year}"
  shared_year_path = "#{shared_path}/dragonfly/#{year}"
  run "rm -rf #{release_year_path}" if File.exists?(release_year_path)
  run "mkdir -p #{shared_year_path}" unless File.exists?(shared_year_path)
  run "ln -nfs #{shared_year_path} #{release_year_path}"
end
run "ln -nfs #{shared_path}/uploads #{release_path}/public/uploads"

run "mkdir -p #{release_path}/uploads"
(2010..Time.now.year+5).each do |year|
  release_year_path = "#{release_path}/uploads/#{year}"
  shared_year_path = "#{shared_path}/doc_uploads/#{year}"
  run "rm -rf #{release_year_path}" if File.exists?(release_year_path)
  run "mkdir -p #{shared_year_path}" unless File.exists?(shared_year_path)
  run "ln -nfs #{shared_year_path} #{release_year_path}"
end

# Setup sphinx
run "rm -rf #{release_path}/db/sphinx"
run "mkdir -p #{shared_path}/sphinx"
run "ln -nfs #{shared_path}/sphinx #{release_path}/db/sphinx"
run "ln -nfs #{shared_path}/production.sphinx.conf #{release_path}/config/production.sphinx.conf"

if release_path =~ /staging/
  fb_yaml_path = "#{release_path}/client/config/facebooker.yml"
  fb_yaml = YAML.load_file(fb_yaml_path)
  fb_yaml['production']['app_id'] = 366926473327119
  fb_yaml['production']['secret'] = '1a3b7de8cab340c8cf336bd42e85d257'
  File.open(fb_yaml_path, 'w') do |file|
    file.puts YAML::dump(fb_yaml)
  end
end