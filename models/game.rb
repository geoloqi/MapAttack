class Game
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :layer_id, String, :length => 12, :index => true
  property :created_at, DateTime
  property :updated_at, DateTime
  has n, :teams
  has n, :player
  
  after :create do
    ['red', 'blue'].each {|color| teams.create :name => color}
  end
  
  def pick_team
  	# At this point we can be sure there are already 2 teams in the game since the game 
  	# was created in the "/games/:layer_id/join"
  	if teams[0].players.count < teams[1].players.count
      team = teams[0]
    else
      team = teams[1]
    end
  end
end