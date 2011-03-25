# ULTRA STEP: MAKE MULTIPLE LAYER SUPPORT = MULTIPLE GAME BOARDS

class PdxPacman < Sinatra::Base

  get '/games/:layer_id/join' do
    @game = Game.first :layer_id => params[:layer_id]
    if @game == nil
      response = Geoloqi.get Geoloqi::OAUTH_TOKEN, 'layer/info/' + params[:layer_id]
      @game = Game.create :layer_id => params[:layer_id], :name => response.name
      @game.teams.create :name => "red"
      @game.teams.create :name => "blue"
    end
    @oauth_token = params[:oauth_token]
    erb :join
  end

  post '/games/:layer_id/join.json' do
    content_type 'application/json'

    #  params[:layer_id] comes from JOIN button
    #  params[:oauth_token] comes in via the query string from the iPhone app

	user_profile = Geoloqi.get params[:oauth_token], 'account/profile'

    @game = Game.first :layer_id => params[:layer_id]

    #  generate shared token so we can retrieve their location for the map later
	shared_token = Geoloqi.post params[:oauth_token], 'link/create', {:description => "Created for "+@game.name}

    #  subscribe the player to the layer
	#Geoloqi.get params[:oauth_token], 'layer/subscribe/' + params[:layer_id]

    @player = Player.first :geoloqi_user_id => user_profile.user_id, :game => @game
    if @player == nil
    	@player = Player.new
	    @player.profile_image = user_profile.profile_image
	    @player.name = user_profile.name
	    @player.geoloqi_user_id = user_profile.user_id
	    @player.token = shared_token.token
	    @player.game = @game
	    # assign the player to a team 
	    # TODO: store the team in the layer subscription?
	    # layer/subscription/:layer_id   :body => {:settings => {:team_id => @team.id}}
	    @player.team = @game.pick_team
	    @player.save
	end

    #  send message to user indicating team
  end

  get '/games/:layer_id/?' do
    @game = Game.first_or_create :layer_id => params[:layer_id]
    erb :'index'
  end

  post '/trigger' do
    body = SymbolTable.new JSON.parse(request.body)
    
    @player = Player.first :game => Game.first(:layer_id => body.layer.layer_id), :geoloqi_user_id => body.user.user_id
    
    if body.place.extra.active.to_i == 1
      Geoloqi.post Geoloqi::OAUTH_TOKEN, "place/update/#{body.place.place_id}", {:extra => {:active => 0}}
      @player.add_points body.place.extra.points if body.place.extra && body.place.extra.points
      @player.send_message "You ate a dot! #{body.place.extra.points} points"
    end
  end

  get '/scores.json' do
    content_type 'application/json'
    players = Player.all.collect{|player| {:geoloqi_id => player.id,
                                           :score => player.points_cache,
                                           :name => player.name,
                                           :profile_image => player.profile_image}}
    players.to_json
  end

  get '/games/:layer_id/setup.json' do
    response = Geoloqi.post Geoloqi::OAUTH_TOKEN, 'place/list', {:layer_id => params[:layer_id]}
    places = []
    response['places'].each do |place|
      places << {:place_id => place['place_id'],
                 :latitude => place['latitude'],
                 :longitude => place['longitude'],
                 :active => place['extra']['active']}
    end
    places.to_json
  end
end