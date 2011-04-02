
class PdxPacman < Sinatra::Base

  get '/game/:layer_id/join' do
    @game = Game.first :layer_id => params[:layer_id]
    if @game == nil
      response = Geoloqi.get Geoloqi::OAUTH_TOKEN, 'layer/info/' + params[:layer_id]
      @game = Game.create :layer_id => params[:layer_id], :name => response.name
      @game.teams.create :name => "red"
      @game.teams.create :name => "blue"
    end
    @oauth_token = params[:oauth_token]
    
    response = Geoloqi.get @oauth_token, 'layer/info/' + params[:layer_id]
    
    if response.subscription.nil? || response.subscription == false || response.subscription.subscribed.to_i == 0
	    erb :join
	else
    	redirect "/game/" + params[:layer_id] + "/mobile"
    end
  end

  post '/game/:layer_id/join.json' do
    content_type 'application/json'
	  user_profile = Geoloqi.get params[:oauth_token], 'account/profile'
    @game = Game.first :layer_id => params[:layer_id]

    #  generate shared token so we can retrieve their location for the map later
	  shared_token = Geoloqi.post params[:oauth_token], 'link/create', {:description => "Created for "+@game.name}

    #  subscribe the player to the layer
	  Geoloqi.get params[:oauth_token], 'layer/subscribe/' + params[:layer_id]

    @player = Player.first :geoloqi_user_id => user_profile.user_id, :game => @game
    if @player == nil
    	@player = Player.new
	    @player.profile_image = user_profile.profile_image
	    @player.name = user_profile.username
	    @player.geoloqi_user_id = user_profile.user_id
	    @player.token = shared_token.token
	    @player.game = @game
	    # assign the player to a team 
	    # TODO: store the team in the layer subscription?
	    # layer/subscription/:layer_id   :body => {:settings => {:team_id => @team.id}}
	    @player.team = @game.pick_team
	    @player.save
	end

    # send message to user indicating team
    @player.send_message("You're on the " + @player.team.name + " team!").to_json
  end

  get '/game/:layer_id/mobile' do
    @game = Game.first_or_create :layer_id => params[:layer_id]
    erb :'mobile'
  end

  get '/game/:layer_id/?' do
    @game = Game.first_or_create :layer_id => params[:layer_id]
    erb :'index'
  end

  post '/trigger' do
    body = SymbolTable.new JSON.parse(request.body)
    
    @player = Player.first :game => Game.first(:layer_id => body.layer.layer_id), :geoloqi_user_id => body.user.user_id
    
    if body.place.extra.active.to_i == 1
      Geoloqi.post Geoloqi::OAUTH_TOKEN, "place/update/#{body.place.place_id}", {:extra => {:active => 0, :team => @player.team.name}}
      @player.add_points body.place.extra.points if body.place.extra && body.place.extra.points
      @player.send_message "You ate a dot! #{body.place.extra.points} points"
    end
  end

  get '/game/:layer_id/status.json' do
    # content_type 'application/json'

    response = Geoloqi.post Geoloqi::OAUTH_TOKEN, 'place/list', {:layer_id => params[:layer_id]}

	@game = Game.first :layer_id => params[:layer_id]

    places = []
    response['places'].each do |place|
      places << {:place_id => place['place_id'],
                 :latitude => place['latitude'],
                 :longitude => place['longitude'],
                 :points => place['extra']['points'],
                 :team => place['extra']['team'],
                 :active => place['extra']['active']}
    end
    
    @tokens = []
    @game.player.each do |player|
      @tokens.push player.token
    end
    response = Geoloqi.get Geoloqi::OAUTH_TOKEN, 'share/last?geoloqi_token=,' + @tokens.join(",")

    players = []
    @game.player(:order => :points_cache.desc).each do |player|
    	location = {}
    	response.each do |p|
    	  if p['username'] == player.name
    	    location = p
    	  end
    	end
    
    	players << {:geoloqi_id => player.id,
	                   :score => player.points_cache,
	                   :name => player.name,
	                   :team => player.team.name,
	                   :profile_image => player.profile_image,
	                   :location => location}
    end


    {:places => places, :players => players}.to_json
  end
end
