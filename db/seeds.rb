Tramlines::load_plugins

@default_members = [
  Member.new(:forename => 'Si', :surname => 'Wilkins', :email => 'si@yoomee.com', :username => 'si', :password => 'olive123', :is_admin => true),
  Member.new(:forename => 'Andy', :surname => 'Mayer', :email => 'andy@yoomee.com', :username => 'andy', :password => 'olive123', :is_admin => true),
  Member.new(:forename => 'Nicola', :surname => 'Mayer', :email => 'nicola@yoomee.com', :username => 'nicola', :password => 'olive123', :is_admin => true),
  Member.new(:forename => 'Rich', :surname => 'Wells', :email => 'rich@yoomee.com', :username => 'rich', :password => 'olive123', :is_admin => true),
  Member.new(:forename => 'Ian', :surname => 'Mooney', :email => 'ian@yoomee.com', :username => 'ian', :password => 'olive123', :is_admin => true),
  Member.new(:forename => 'Rob', :surname => 'Parvin', :email => 'rob@yoomee.com', :username => 'rob', :password => 'olive123', :is_admin => true),
  Member.new(:forename => 'Matt', :surname => 'Atkins', :email => 'matt@yoomee.com', :username => 'matt', :password => 'olive123', :is_admin => true),
]
PhotoAlbum.create!(:name => 'System Images', :system_album => true)
Section.create!(:name => "About Us", :slug => "about_us", :view => "normal", :weight => 0)
Section.create!(:name => "News", :slug => "news", :view => "latest_stories", :weight => 0)
Page.create!(:title => "About Us", :slug => "about_us_page", :text => "This is what we are about.", :section_id => 1)

CLIENT_SEED_FILE = "#{RAILS_ROOT}/client/db/seeds.rb"
eval(File.read(CLIENT_SEED_FILE), binding, CLIENT_SEED_FILE) if File.exists?(CLIENT_SEED_FILE)

@default_members.each(&:save!)