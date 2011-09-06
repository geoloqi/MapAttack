class Controller < Sinatra::Base

  before do
    puts "REQUEST URL: #{request.url}"
    puts "PARAMS: #{params.inspect}" 
  end

  after do
    session[:geoloqi_auth] = geoloqi.auth
  end

  get '/?' do
    erb :'index_stub'
  end

  get '/admin/games' do
    @games = Game.all
    erb :'admin/games/index', :layout => :'admin/layout'
  end

  get '/admin/games/new' do
    @game = Game.new
    erb :'admin/games/new', :layout => :'admin/layout'
  end

  post '/admin/games' do
    game = Game.new params[:game]
    group_response = geoloqi_app.post 'group/create', :visibility => 'open', :publish_access => 'open'
    layer_response = geoloqi_app.post 'layer/create', :name => game.name,
                                                      :latitude => game.latitude,
                                                      :longitude => game.longitude,
                                                      :radius => game.radius,
                                                      :public => 1,
                                                      :is_app => 1
    geoloqi_app.post "group/join/#{group_response.group_token}"
    game.layer_id = layer_response.layer_id
    game.group_token = group_response.group_token
    game.save
    redirect "/admin/games"
  end

  get '/admin/games/:id/edit' do
    @game = Game.get params[:id]
    erb :'admin/games/edit', :layout => :'admin/layout'
  end

  put '/admin/games/:id' do
    @game = Game.get params[:id]
    @game.update params[:game]
    
    layer_response = geoloqi_app.post "layer/update/#{@game.layer_id}", :name => @game.name,
                                                                        :latitude => @game.latitude,
                                                                        :longitude => @game.longitude,
                                                                        :radius => @game.radius
    redirect '/admin/games'
  end

  delete '/admin/games/:id' do
    #@game = Game.get params[:id]
    #geoloqi_app.post "layer/delete/#{@game.layer_id}"
    ### geoloqi_app.post "group/delete/#{@game.group_token}"  NOT IMPLEMENTED YET
    #@game.destroy
    #redirect '/'
  end

  post '/game/:layer_id/join' do
    content_type :json
    geoloqi = Geoloqi::Session.new :auth => {:access_token => params[:access_token]}
    game = Game.first :layer_id => params[:layer_id]
    player = Player.first :access_token => params[:access_token]
    unless player
      profile = geoloqi.get 'account/profile'
      player = game.players.create :access_token => params[:access_token], :email => params[:email], :name => params[:initials], :team => game.pick_team, :geoloqi_user_id => profile.user_id
      geoloqi.post "group/join/#{game.group_token}"
      geoloqi.post "layer/subscribe/#{game.layer_id}"
      geoloqi.post 'message/send', :text => "You're on the #{player.team.name} team!"
    end
    {'team_name' => player.team.name}.to_json
  end

=begin
  get '/game/:layer_id/join' do
    require_login
    game = Game.first :layer_id => params[:layer_id]

   	user_profile = geoloqi.get 'account/profile'

    player = Player.first :geoloqi_user_id => user_profile.user_id, :game => game

    layer_info = geoloqi_app.get "layer/info/#{params[:layer_id]}"

    if layer_info.subscription.nil? || layer_info.subscription == false || player.nil? # This conditional needs cleaning.

      # The player has never subscribed to the layer before, so create a new record in our DB and add them to the group.

      # Add them to the group, so Geoloqi will publish their locations to this group.
    	geoloqi.post "group/join/#{game.group_token}"

      # Subscribe the player to the layer. This enables geofencing for this user for all the places on the layer.
    	geoloqi.get "layer/subscribe/#{game.layer_id}"

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
=end

  get '/game/:layer_id/?' do
    @game = Game.first :layer_id => params[:layer_id]
    erb :'index'
  end

  post '/trigger' do
    body = Hashie::Mash.new JSON.parse(request.body.read)

    game = Game.first :layer_id => body.layer.layer_id
    player = Player.first :game => game, :geoloqi_user_id => body.user.user_id

    if body.place.extra.active.to_i == 1
      # Update the place info in Geoloqi to set it inactive and record the team that ate the coin
      geoloqi_app.post "place/update/#{body.place.place_id}", :extra => {:active => 0, :team => player.team.name}

      # Add points to this player's score
      player.add_points body.place.extra.points if body.place.extra && body.place.extra.points

      # TODO: Calculate the total red/blue score here
      score_red = game.teams.first(:name => 'red').players.collect {|p| p.points_cache}.sum
      score_blue = game.teams.first(:name => 'blue').players.collect {|p| p.points_cache}.sum

      # Broadcast the coin state to the group
      geoloqi_app.post "group/message/#{game.group_token}", {
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
      geoloqi_app.post 'message/send', :user_id => player.geoloqi_user_id, :text => "You ate a dot! #{body.place.extra.points} points"
    end
    true
  end

  get '/game/:layer_id/status.json' do
    content_type 'application/json'
    response = geoloqi_app.get 'place/list', :layer_id => params[:layer_id], :after => params[:after]
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

    locations = geoloqi_app.get("group/last/#{game.group_token}")['locations']

    players = []
    game.players(:order => :points_cache.desc).each do |player|
    	player_location = {}

    	locations.each {|p| player_location = p if p['user_id'] == player.geoloqi_user_id }

    	players << {:geoloqi_id => player.geoloqi_user_id,
                  :score => player.points_cache,
	                :name => player.name,
	                :team => player.team.name,
	                :profile_image => player.profile_image,
	                :location => player_location}
    end
    {:places => places, :players => players}.to_json
  end

  get '/player/:geoloqi_user_id' do
    puts "GEOLOQI USER ID: #{params[:geoloqi_user_id]}"
    content_type :json
    player = Player.first :geoloqi_user_id => params[:geoloqi_user_id]
    return {'error' => 'player_not_found'}.to_json if player.nil?
    {:team => player.team.name.downcase, :profile_image => player.profile_image, :name => player.name}.to_json
  end

  get '/player/:player_id/:team/map_icon.png' do
    file_path = File.join Controller.root, "public", "icons", "#{params[:player_id]}_#{params[:team]}.png"
    file_path_tmp = "#{file_path}tmp"
    generic_icon_path = File.join Controller.root, "public", "img", "mini-dino-" + params[:team] + ".png"
    marker_path = File.join Controller.root, "public", "img", "player-icon-" + params[:team] + ".png"

    if File.exist?(file_path)
      send_file file_path
    else
      player = Player.first :geoloqi_user_id => params[:player_id]
      if !player.profile_image.nil? && player.profile_image != ''
        File.open(file_path_tmp, 'w') {|f| f.write(Faraday.get(player.profile_image).body) }
        `mogrify -resize 16x16^ -crop 16x16+0+0 -gravity north #{file_path_tmp}`
      else
        FileUtils.cp generic_icon_path, file_path_tmp
      end

      `composite -geometry +3+3 -compose Over #{file_path_tmp} #{marker_path} #{file_path_tmp}`
      FileUtils.mv file_path_tmp, file_path
      send_file file_path
    end
  end

  post '/contact_submit' do
    Faraday.post 'http://business.geoloqi.com/contact-submit.php', params
    {:result => "ok"}.to_json
  end

  get '/authorize' do
    geoloqi.get_auth(params[:code], request.url) if params[:code] && !geoloqi.access_token?
    redirect "/#{params[:state]}"
  end

  def require_login
    redirect geoloqi.authorize_url("#{request.url_without_path}/authorize", :state => request.path[1..request.path.length]) unless geoloqi.access_token?
  end

  def geoloqi
    @geoloqi ||= Geoloqi::Session.new :auth => session[:geoloqi_auth]
  end
end
