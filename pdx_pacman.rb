# ULTRA STEP: MAKE MULTIPLE LAYER SUPPORT = MULTIPLE GAME BOARDS

class PdxPacman < Sinatra::Base

  get '/games/:layer_id/join' do
    erb :join
  end

  post '/games/:layer_id/join.json' do
    content_type 'application/json'

    #  params[:layer_id] comes from JOIN button
    # Also: params[:access_token]
    #  generate shared_token
    #  subscribe the player to the layer
    #  pick a team and record
    #  send message to user indicating team
  end

  get '/?' do
    erb :'index'
  end

  post '/trigger' do
    puts "@@@@@@@@@@@@@ ENTERING TRIGGER"
    json = JSON.parse request.body
    puts "@@@@@@@@@@@@@ JSON: #{json.inspect}"
    @player = Player.first_or_create :geoloqi_id => json['user']['user_id']
    @player.profile_image = json['user']['profile_image']
    @player.name = json['user']['name']
    @player.save

    if json['place']['extra']['active'] == '1'
      eat_dot json['place']['place_id']
      @player.add_points json['place']['extra']['points'] if json['place']['extra']['points']
      send_message @player.geoloqi_id, "You ate a dot! #{json['place']['extra']['points']} points"
    end
    ''
  end

  get '/scores.json' do
    content_type 'application/json'
    players = Player.all.collect{|player| {:geoloqi_id => player.id, :score => player.points_cache, :name => player.name, :profile_image => player.profile_image}}
    players.to_json
  end

  get '/setup.json' do
    pellets_raw = get_pellets
    json = JSON.parse get_pellets
    places = []

    json['places'].each do |place|
      places << {:place_id => place['place_id'], :latitude => place['latitude'], :longitude => place['longitude'], :active => place['extra']['active']}
    end
    places.to_json
  end

  post '/register' do
    @browser = Browser.first_or_create :jabber_id => params[:jabber_id]
  end

  private

  def send_message(user_id, text)
    request = Typhoeus::Request.new("https://api.geoloqi.com/1/message/send",
                                    :body    => {:user_id => user_id, :text => text}.to_json,
                                    :method  => :post,
                                    :headers => {'Authorization' => "OAuth #{GEOLOQI_OAUTH_TOKEN}",
                                                 'Content-Type' => 'application/json'})
    hydra = Typhoeus::Hydra.new
    hydra.queue request
    hydra.run
    puts "@@@@@@@@ SEND_MESSAGE RESPONSE: #{request.response.body.inspect}"
    request.response.body
  end

  def get_pellets
    # FIXME set layer_id dynamically  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    request = Typhoeus::Request.new("https://api.geoloqi.com/1/place/list",
                          :body          => 'layer_id=1L6',
                          :method        => :post,
                          :headers       => {'Authorization' => "OAuth #{GEOLOQI_OAUTH_TOKEN}"})
    hydra = Typhoeus::Hydra.new
    hydra.queue request
    hydra.run
    request.response.body
  end

  def eat_dot(place_id)
    # TODO: ADD IN TEAM AND PLAYER TO EXTRA JSON
    # team_id  and user_id
    # two teams only for now

    request = Typhoeus::Request.new("https://api.geoloqi.com/1/place/update/#{place_id}",
                                    :body    => {:extra => {:active => 0}}.to_json,
                                    :method  => :post,
                                    :headers => {'Authorization' => "OAuth #{GEOLOQI_OAUTH_TOKEN}", 'Content-Type' => 'application/json'})
    hydra = Typhoeus::Hydra.new
    hydra.queue request
    hydra.run
    puts "@@@@@@@@ EAT_DOT RESPONSE: #{request.response.body.inspect}"
    request.response.body
  end
end