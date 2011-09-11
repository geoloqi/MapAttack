# Encoding.default_internal = 'UTF-8'
#$stderr.reopen $stdout
require "rubygems"
require "bundler"
Bundler.setup
Bundler.require
require 'rack/methodoverride'

class Sinatra::Base
  helpers do
    def partial(page, options={})
      erb page, options.merge!(:layout => false)
		end

    def h(val)
      Rack::Utils.escape_html val
    end

    def require_login
      geoloqi.get_auth(params[:code], request.url) if params[:code] && !geoloqi.access_token?
      redirect geoloqi.authorize_url(request.url) unless geoloqi.access_token?
    end
    
    def geoloqi_app
      @_geoloqi_app ||= Geoloqi::Session.new :access_token => APPLICATION_ACCESS_TOKEN
    end
  end

  configure :development do
    DataMapper::Logger.new STDOUT, :debug
  end

  configure do
    use Rack::MobileDetect
    # register Sinatra::Synchrony
    if test?
      set :sessions, false
    else
      set :sessions, true
      set :session_secret,  'PUT SECRET HERE'
    end

    set :root, File.expand_path(File.join(File.dirname(__FILE__)))
    set :public, File.join(root, 'public')
    set :display_errors, true
    set :method_override, true
    mime_type :woff, 'application/octet-stream'
    Dir.glob(File.join(root, 'models', '**/*.rb')).each { |f| require f }
    config_hash = YAML.load_file(File.join(root, 'config.yml'))[environment.to_s]
    raise "in config.yml, the \"#{environment.to_s}\" configuration is missing" if config_hash.nil?
    GA_ID = config_hash['ga_id']
    APPLICATION_ACCESS_TOKEN = config_hash['oauth_token']
    # Faraday.default_adapter = :em_synchrony
    Geoloqi.config :client_id => config_hash['client_id'],
                   :client_secret => config_hash['client_secret'],
                   :use_hashie_mash => true
    DataMapper.finalize
    DataMapper.setup :default, ENV['DATABASE_URL'] || config_hash['database']
    # DataMapper.auto_upgrade!
    DataMapper::Model.raise_on_save_failure = true
  end
end

# Monkey patch fix for migrations bug on JRuby
DataMapper.repository.adapter.class.class_eval do
  def show_variable(name)
    select('SELECT variable_value FROM information_schema.session_variables WHERE LOWER(variable_name) = ?', name).first
  end
end

# Quit whining about the certificate!
require 'openssl'
original_verbosity = $VERBOSE
$VERBOSE = nil
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
$VERBOSE = original_verbosity

module Rack
  class Request
    def url_without_path
      url = scheme + "://"
      url << host

      if scheme == "https" && port != 443 ||
        scheme == "http" && port != 80
        url << ":#{port}"
      end
      url
    end
  end
end

class Array; def sum; inject( nil ) { |sum,x| sum ? sum+x : x }; end; end

require File.join(Sinatra::Base.root, 'controller.rb')
