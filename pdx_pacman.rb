# ULTRA STEP: MAKE MULTIPLE LAYER SUPPORT = MULTIPLE GAME BOARDS

class PdxPacman < Sinatra::Base

  get '/games/:layer_id/join' do
    @game = Game.find_or_create :layer_id => params[:layer_id]
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
      @player.send_message "You ate a dot! #{json['place']['extra']['points']} points"
    end
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

  end

  def get_pellets
    # FIXME set layer_id dynamically
    raise 'go to Geoloqi::Place.list'
  end

  def eat_dot(place_id)
    raise 'place/update'
  end
end