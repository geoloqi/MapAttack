class Controller < Sinatra::Base

  after do
    session[:geoloqi_auth] = geoloqi.auth
  end

  get '/?' do
    erb :'index_stub'
  end

  get '/game/:layer_id/join' do
    geoloqi.get_auth(params[:code], request.url) if params[:code] && !geoloqi.access_token?
    redirect geoloqi.authorize_url(request.url) unless geoloqi.access_token?

    game = Game.create_unless_exists geoloqi, params[:layer_id]

   	user_profile = geoloqi.get 'account/profile'

    player = Player.first :geoloqi_user_id => user_profile.user_id, :game => game

    layer_info = geoloqi.get "layer/info/#{params[:layer_id]}"

    if layer_info.subscription.nil? || layer_info.subscription == false || player.nil? # This conditional needs cleaning.

      # The player has never subscribed to the layer before, so create a new record in our DB and add them to the group.

      # Add them to the group, so Geoloqi will publish their locations to this group.
    	shared_token = geoloqi.post 'group/join/#{game.group_token}'

      # Subscribe the player to the layer. This enables geofencing for this user for all the places on the layer.
    	geoloqi.get "layer/subscribe/#{params[:layer_id]}"

	    if player.nil?
	      player = Player.new :name => user_profile.username,
	                           :geoloqi_user_id => user_profile.user_id,
	                           :game => game,
	                           :team => game.pick_team

          # If user_profile.profile_image is not there or is null, don't do this (Should prevent errors on non-twitter accounts)
          player.profile_image = user_profile.profile_image unless user_profile.profile_image.nil? || user_profile.profile_image.empty?
          player.save
        end

        geoloqi.post 'message/send', :user_id => player.geoloqi_user_id, :text => "You're on the #{player.team.name} team!"
    end
    redirect "/game/" + params[:layer_id]
  end

  get '/game/:layer_id/?' do
    begin
      @game = Game.create_unless_exists geoloqi, params[:layer_id]
    rescue Geoloqi::Error
      redirect '/'
    end
    erb :'index'
  end

  post '/trigger' do
    body = Hashie::Mash.new JSON.parse(request.body)

    game = Game.first(:layer_id => body.layer.layer_id)
    player = Player.first :game => game, :geoloqi_user_id => body.user.user_id

    if body.place.extra.active.to_i == 1
      # Update the place info in Geoloqi to set it inactive and record the team that ate the coin
      geoloqi.post "place/update/#{body.place.place_id}", :extra => {:active => 0, :team => player.team.name}

      # Add points to this player's score
      player.add_points body.place.extra.points if body.place.extra && body.place.extra.points

      # TODO: Calculate the total red/blue score here
      score_red = 0
      score_blue = 0

      # Broadcast the coin state to the group
      geoloqi.post 'group/message/#{game.group_token}', {
        :mapattack => {
          :place_id => body.place.place_id,
          :team => player.team.name,
          :points => body.place.extra.points,
          :latitude => body.place.latitude,
          :longitude => body.place.longitude,
          :score_red => score_red,
          :score_blue => score_blue
        }
      }

      # Notify the user that they ate the dot
      geoloqi.post 'message/send', :user_id => player.geoloqi_user_id, :text => "You ate a dot! #{body.place.extra.points} points"
    end
    true
  end

  get '/game/:layer_id/status.json' do
    content_type 'application/json'
    response = Geoloqi.get APPLICATION_ACCESS_TOKEN, 'place/list', :layer_id => params[:layer_id], :after => params[:after]
    # response = geoloqi.get 'place/list', :layer_id => params[:layer_id], :after => params[:after]

    game = Game.first :layer_id => params[:layer_id]

    places = []
    response['places'].each do |place|
      places << {:place_id => place['place_id'],
                 :latitude => place['latitude'],
                 :longitude => place['longitude'],
                 :points => place['extra']['points'],
                 :team => place['extra']['team'],
                 :active => place['extra']['active']}
    end

    tokens = []
    game.player.each do |player|
      tokens.push player.token
    end

    # TODO: update to use group/last/:group_token to retrieve all user's locations
    locations = geoloqi.get("share/last?geoloqi_token=,#{tokens.join ','}").locations

    players = []
    game.player(:order => :points_cache.desc).each do |player|
    	player_location = {}
    	
    	locations.each {|p| player_location = p if p['username'] == player.name }

    	players << {:geoloqi_id => player.geoloqi_user_id,
                  :score => player.points_cache,
	                :name => player.name,
	                :team => player.team.name,
	                :profile_image => player.profile_image,
	                :location => player_location}
    end
    {:places => places, :players => players}.to_json
  end

  get '/player/:player_id/:team/map_icon.png' do
    filename = File.join Controller.root, "public", "icons", "#{params[:player_id]}_#{params[:team]}.png"
    if File.exist?(filename)
      send_file filename
    else
      player = Player.first :geoloqi_user_id => params[:player_id]
      if !player.profile_image.nil? && player.profile_image != ''
        playerImg = Magick::Image.read(player.profile_image).first
        playerImg.crop_resized!(16, 16, Magick::NorthGravity)
      else
        playerImg = Magick::Image.read(File.join(Controller.root, "public", "img", "mini-dino-" + params[:team] + ".png")).first
      end
      markerIcon = Magick::Image.read(File.join(Controller.root, "public", "img", "player-icon-" + params[:team] + ".png")).first
      result = markerIcon.composite(playerImg, 3, 3, Magick::OverCompositeOp)
      result.write(filename)
      send_file filename
    end
  end

  post '/contact_submit' do
    Faraday.post 'http://business.geoloqi.com/contact-submit.php', params
    {:result => "ok"}.to_json
  end

  def geoloqi
    @geoloqi ||= Geoloqi::Session.new :auth => session[:geoloqi_auth]
  end
end
