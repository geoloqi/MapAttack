# Encoding.default_internal = 'UTF-8'
require "rubygems"
require "bundler"
Bundler.setup
Bundler.require

class Sinatra::Base
  configure do
    use Rack::FiberPool
    use Rack::Cache, :verbose => false,
                     :metastore => "file:cache/meta",
                     :entitystore => "file:cache/body"
    set :root, File.expand_path(File.join(File.dirname(__FILE__)))
    set :public, File.join(root, 'public')
    Dir.glob(File.join(root, 'models', '**/*.rb')).each { |f| require f }
    config_hash = YAML.load_file(File.join(root, 'config.yml'))[environment.to_s]
    Geoloqi::OAUTH_TOKEN = config_hash['oauth_token']
    Geoloqi::CLIENT_ID = config_hash['client_id']
    Geoloqi::CLIENT_SECRET = config_hash['client_secret']
    Geoloqi::BASE_URI = config_hash['base_uri']
    Geoloqi::GA_ID = config_hash['ga_id']

    DataMapper.finalize
    DataMapper.setup :default, ENV['DATABASE_URL'] || config_hash['database']
    # DataMapper.auto_upgrade!
    DataMapper::Model.raise_on_save_failure = true
=begin
    EM.next_tick do
      scheduler = Rufus::Scheduler::EmScheduler.start_new
      scheduler.every '1s' do
        puts "LOL!"
      end
    end
=end
  end
end

require File.join(Sinatra::Base.root, 'pdx_pacman.rb')
