class Controller < Sinatra::Base

  before do
  	@current_page = request.path[/(\w|-)+/]
    if request.path =~ /^\/admin\//
      require_login
      geoloqi.get_auth(params[:code], request.url) if params[:code] && !geoloqi.access_token?
      admins_only
    end
  end

  after do
    session[:geoloqi_auth] = geoloqi.auth
  end

  get '/?' do
    erb :'splash', :layout => false
  end

  get '/admin' do
    redirect '/admin/games'
  end

  get '/admin/games' do
    @games = Game.all
    erb :'admin/games/index', :layout => :'admin/layout'
  end

  get '/admin/games/new' do
    @game = Game.new
    erb :'admin/games/new', :layout => :'admin/layout'
  end

  get '/admin/games/:id/mapeditor' do
    @game = Game.get params[:id]
    erb :'admin/games/mapeditor', :layout => false
  end

  post '/admin/games' do
    game = Game.new params[:game]
    group_response = geoloqi_app.post 'group/create', :visibility => 'open', :publish_access => 'open'
    layer_response = geoloqi_app.post 'layer/create', :name => game.name,
                                                      :latitude => game.latitude,
                                                      :longitude => game.longitude,
                                                      :radius => game.radius,
                                                      :public => 1,
                                                      :trigger_rate_limit => 0,
                                                      :is_app => 1
    geoloqi_app.post "group/join/#{group_response.group_token}"
    geoloqi_app.post 'trigger/create', :layer_id => layer_response.layer_id, :type => 'callback', :callback => "http://mapattack.org/trigger", :one_time => 0
    game.layer_id = layer_response.layer_id
    game.group_token = group_response.group_token
    game.save
    redirect "/admin/games/#{game.id}/mapeditor"
  end

  get '/admin/games/:layer_id/setup.json' do
    content_type :json
    geoloqi_app.get('place/list', :layer_id => params[:layer_id], :limit => 0).to_json
  end
  
  put '/admin/games/:id/reset' do
    game = Game.get params[:id]
    result = geoloqi_app.get 'place/list', :layer_id => game.layer_id, :limit => 0
    
    places = []
    
    result.places.each do |place|
      place.extra.active = 1
      place.extra.team = ''
      places << place
    end
    
    query = {:access_token => geoloqi_app.access_token, :batch => places.collect!{|place| {:relative_url => "place/update/#{place.place_id}", :body => {:extra => place.extra}}}}

    result = geoloqi_app.execute :post, 'batch/run', query
    redirect '/admin/games'
  end

  post '/admin/games/:layer_id/new_pellet.json' do
    content_type :json
    place_response = geoloqi_app.post "place/create", :name => "#{Time.now.to_i}-#{rand 10000}",
                                                      :latitude => params[:latitude],
                                                      :longitude => params[:longitude],
                                                      :radius => 20,
                                                      :layer_id => params[:layer_id],
                                                      :extra => {
                                                      	:active => 1, 
                                                      	:points => (params[:post] || 10),
                                                      	:text => ""
                                                      }
    geoloqi_app.get("place/info/#{place_response.place_id}").to_json
  end
  
  post '/admin/games/:layer_id/move_pellet.json' do
    content_type :json
    place_response = geoloqi_app.post("place/update/#{params[:place_id]}", :latitude => params[:latitude], :longitude => params[:longitude]).to_json
  end
  
  post '/admin/games/:layer_id/delete_pellet.json' do
    content_type :json
    geoloqi_app.post("place/delete/#{params[:place_id]}").to_json
  end
  
  post '/admin/games/:layer_id/batch_create_pellets.json' do
    content_type :json
    points = []
    params[:locations].split('|').each do |location|
      place_data = {:name => "#{Time.now.to_i}-#{rand 10000}",
                    :latitude => location.split(',').first,
                    :longitude => location.split(',').last,
                    :radius => 20,
                    :layer_id => params[:layer_id],
                    :extra => {
                    	:active => 1, 
                    	:points => (params[:post] || 10), 
                    	:text => ""
                    }}

      place_response = geoloqi_app.post "place/create", place_data

      unless place_response.place_id.nil?
        place_data[:place_id] = place_response.place_id
        points << place_data
      end
    end
    {:result => 'ok', :points => points}.to_json
  end

  post '/admin/games/:layer_id/set_pellet_value.json' do
    content_type :json
    geoloqi_app.post("place/update/#{params[:place_id]}", :radius => '20', :extra => {:active => '1', :text => params[:text], :points => params[:points]}).to_json
  end

  post '/admin/games/:layer_id/set_pellet_text.json' do
    content_type :json
    geoloqi_app.post("place/update/#{params[:place_id]}", :extra => {:active => '1', :text => params[:text]}).to_json
  end

  get '/admin/games/:id/edit' do
    @game = Game.get params[:id]
    erb :'admin/games/edit', :layout => :'admin/layout'
  end

  put '/admin/games/:id/end_game' do
    @game = Game.get params[:id]
    geoloqi_app.post "group/message/#{@game.group_token}", :mapattack => {:gamestate => 'done'}
    redirect '/admin/games'
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
    @game = Game.get params[:id]
    geoloqi_app.post "layer/delete/#{@game.layer_id}"
    ## geoloqi_app.post "group/delete/#{@game.group_token}"  NOT IMPLEMENTED YET
    @game.destroy
    redirect '/admin/games'
  end

  post '/game/:layer_id/join' do
    content_type :json
    geoloqi = Geoloqi::Session.new :auth => {:access_token => params[:access_token]}
    game = Game.first :layer_id => params[:layer_id]
    player = Player.first :access_token => params[:access_token], :game => game
    unless player
      profile = geoloqi.get 'account/profile'
      player = game.players.create :access_token => params[:access_token], :email => params[:email], :name => params[:initials].upcase, :team => game.pick_team, :geoloqi_user_id => profile.user_id
      geoloqi.post "group/join/#{game.group_token}"
      geoloqi.post "layer/subscribe/#{game.layer_id}"
      # geoloqi.post 'message/send', :text => "You're on the #{player.team.name} team!"
    end
    {'team_name' => player.team.name, 'user_id' => player.geoloqi_user_id}.to_json
  end

  get '/game/:layer_id/complete' do
    @game = Game.first :layer_id => params[:layer_id]
	@winner = (@game.points_for('red') > @game.points_for('blue') ? 'red' : 'blue')
    erb :'complete'
  end

  get '/replay/:layer_id/?' do
    @game = Game.first :layer_id => params[:layer_id]
    @user_id = nil
    @user_team = ''
    @user_initials = ''
    erb :'index'
  end
  
  get '/game/:layer_id/?' do
    @game = Game.first :layer_id => params[:layer_id]
    @user_id = params[:user_id]
    player = Player.first :geoloqi_user_id => params[:user_id], :game => @game
    @user_team = player ? player.team.name : ''
    @user_initials = player ? player.name : ''
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
          :triggered_user_id => player.geoloqi_user_id,
          :triggered_name => player.name,
          :points => body.place.extra.points,
          :latitude => body.place.latitude,
          :longitude => body.place.longitude,
          :score_red => score_red,
          :score_blue => score_blue
        }
      }

      scores = {}
      game.players.each do |player|
        scores[player.geoloqi_user_id] = player.points_cache
      end

      geoloqi_app.post "group/message/#{game.group_token}", :mapattack => {:scores => scores}

      # Notify the user that they ate the dot (handled differently now)
      # geoloqi_app.post 'message/send', :user_id => player.geoloqi_user_id, :text => "You ate a dot! #{body.place.extra.points} points"
    end
    true
  end

  get '/game/:layer_id/status.json' do
    content_type 'application/json'
    response = geoloqi_app.get 'place/list', :layer_id => params[:layer_id], :after => params[:after], :limit => 0
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

  get '/game/:layer_id/player/:geoloqi_user_id' do
    content_type :json
    game = Game.first :layer_id => params[:layer_id]
    player = Player.first :geoloqi_user_id => params[:geoloqi_user_id], :game => game
    return {'error' => 'player_not_found'}.to_json if player.nil?
    {:team => player.team.name.downcase, :profile_image => player.profile_image, :name => player.name}.to_json
  end

  get '/player/:i1/:i2/:team/map_icon.png' do
    params[:i1] = params[:i1].upcase
    params[:i2] = params[:i2].upcase
    file_path = File.join Controller.root, "public", "icons", "#{params[:i1]}#{params[:i2]}_#{params[:team]}.png"
    file_path_tmp = "#{file_path}tmp"
    marker_path = File.join Controller.root, "public", "img", "player-icon-" + params[:team] + ".png"

    if File.exist?(file_path)
      send_file file_path
    else
      file_path_1 = File.join Controller.root, "public", "characters", params[:i1]+".png"
      file_path_2 = File.join Controller.root, "public", "characters", params[:i2]+".png"

        `convert \\( #{marker_path} \\( -geometry +11+6 -compose Over \\( #{file_path_2} -resize 130% \\) \\) -composite \\) \\( -geometry +2+6 -compose Over \\( #{file_path_1} -resize 130% \\) \\) -composite #{file_path_tmp}`
        FileUtils.mv file_path_tmp, file_path
        send_file file_path
    end
  end

  post '/contact_submit' do
    redirect '/' unless params[:vegancheese] == 'galaxy' # SPAM check

    ses = AWS::SES::Base.new :access_key_id => Controller::AWS_KEY, :secret_access_key => Controller::AWS_SECRET

    ses.send_email :to        => '"MapAttack" <play@mapattack.org>',
                   :source    => '"MapAttack Website" <website@geoloqi.com>',
                   :reply_to  => params[:email],
                   :subject   => 'MapAttack Contact Form',
                   :text_body => "Name: #{params[:name]}\nLocation: #{params[:location]}\n#{params[:message]}"


    {:result => "ok"}.to_json
  end
  
  get '/contact_thanks' do
    erb :'thanks'
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
