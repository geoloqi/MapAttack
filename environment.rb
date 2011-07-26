# Encoding.default_internal = 'UTF-8'
require "rubygems"
require "bundler"
Bundler.setup
Bundler.require

class Sinatra::Base
  configure do
    register Sinatra::Synchrony
    set :sessions, true
    set :session_secret,  'PUT SECRET HERE'
    set :root, File.expand_path(File.join(File.dirname(__FILE__)))
    set :public, File.join(root, 'public')
    mime_type :woff, 'application/octet-stream'
    Dir.glob(File.join(root, 'models', '**/*.rb')).each { |f| require f }
    config_hash = YAML.load_file(File.join(root, 'config.yml'))[environment.to_s]

    Geoloqi::GA_ID = config_hash['ga_id']

    Geoloqi.config :client_id => config_hash['client_id'],
                   :client_secret => config_hash['client_secret'],
                   :adapter => :em_synchrony,
                   :use_hashie_mash => true

    DataMapper.finalize
    DataMapper.setup :default, ENV['DATABASE_URL'] || config_hash['database']
    # DataMapper.auto_upgrade!
    DataMapper::Model.raise_on_save_failure = true
  end
end

require File.join(Sinatra::Base.root, 'controller.rb')
