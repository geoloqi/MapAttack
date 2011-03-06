require "rubygems"
require "bundler"
Bundler.setup
Bundler.require

class PdxPacman < Sinatra::Base
  
  GEOLOQI_OAUTH_TOKEN = 'ba1-138a8e75c1359c5d651120ca760ba8cce20b5f1d'  
  set :public, File.dirname(__FILE__) + '/public'
  
  get '/?' do
    erb :'index'
  end
  
  post '/trigger' do
    json = JSON.parse request.body
    eat_dot json['place']['place_id']
    ''
  end
  
  post '/register' do
    
  end
  
  private
  
  def eat_dot(place_id)
    Typhoeus::Request.new "https://api.geoloqi.com/1/place/update/#{place_id}",
                          :body          => {:extra => {:active => 0}}.to_json,
                          :method        => :post,
                          :headers       => {'Authorization' => "OAuth #{GEOLOQI_OAUTH_TOKEN}", 'Content-Type' => 'application/json'}
  end
end