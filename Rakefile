def init(env=ENV['RACK_ENV']); require File.join('.', 'environment.rb') end

desc "load_oauth_token OAUTH_TOKEN=blahblah"
task :load_oauth_token do
  puts "Storing oauth token in config.yml"
  File.open('config.yml', 'w') {|f| f.write("oauth_token: #{ENV['OAUTH_TOKEN']}") }
end

namespace :db do
  task :bootstrap do
    init
    DataMapper.auto_migrate!
  end
  task :migrate do
    init
    DataMapper.auto_upgrade!
  end
  
end