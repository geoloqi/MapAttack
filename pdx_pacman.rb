require "rubygems"
require "bundler"
Bundler.setup
Bundler.require

class PdxPacman < Sinatra::Base
  
  GEOLOQI_OAUTH_TOKEN = File.read 'oauth_token.txt'
  
  get '/?' do
    erb :'index'
  end
  
  post '/trigger' do
    json_params = JSON.parse request.body
  end
  
  post '/register' do
    
  end
end