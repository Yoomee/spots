begin
  require 'forgery'
rescue LoadError
  # Forgery not found
end  

namespace :fake do

  desc 'Generate [number] fake members'
  task :members, [:number] => :environment do |t, args|
    number = args[:number].to_i.zero? ? 10 : args[:number].to_i
    puts "Faking #{number} members:"
    number.times do |n|
      m = Member.new(
      :forename => Forgery::Name.first_name,
      :surname  => Forgery::Name.last_name
      )
      m.email = "#{m.forename}.#{m.surname}@#{Forgery::Internet.domain_name}".downcase
      m.save
      puts " #{m}"
    end
  end

end

CLIENT_FAKEFILE = File.dirname(__FILE__) + '/../../client/lib/fake.rake'
load CLIENT_FAKEFILE if File.exists?(CLIENT_FAKEFILE)