desc "load_oauth_token OAUTH_TOKEN=blahblah"
task :load_oauth_token do
  puts "Storing oauth token in config.yml"
  File.open('config.yml', 'w') {|f| f.write("oauth_token: #{ENV['OAUTH_TOKEN']}") }
end