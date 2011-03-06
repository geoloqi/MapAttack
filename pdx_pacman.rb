require "rubygems"
require "bundler"
Bundler.setup
Bundler.require

class PdxPacman < Sinatra::Base
  
  get '/?' do
    erb :'index'
  end
  
  post '/trigger' do
    json_params = JSON.parse request.body
    
  end
  
  post '/register' do
    
  end
end