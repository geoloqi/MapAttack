class Game
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :layer_id, String, :length => 12, :index => true
  property :group_token, String, :length => 9
  property :created_at, DateTime
  property :updated_at, DateTime
  has n, :teams
  has n, :player

  after :create do
    ['red', 'blue'].each {|color| teams.create :name => color}
  end

  def self.create_unless_exists(session, layer_id)
    game = first :layer_id => layer_id
    unless game
      puts session.inspect
      response = session.get "layer/info/" + layer_id
      # Create a new group for this game. Players will be added to the group when they join.
      # Group permissions are "open" which allows players to add themselves to the group without prior permission.
      group = session.post "group/create", :visibility => 'open', :publish_access => 'open'
      game = create :layer_id => layer_id, :group_token => group.token, :name => response.name
    end
    game
  end

  def pick_team
  	# At this point we can be sure there are already 2 teams in the game since the game
  	# was created in the "/games/:layer_id/join"
  	team = (teams.first.players.count < teams.last.players.count ? teams.first : teams.last)
  end
end