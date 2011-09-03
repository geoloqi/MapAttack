class Game
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :latitude, String
  property :longitude, String
  property :radius, String
  property :layer_id, String, :length => 12, :index => true
  property :group_token, String, :length => 9
  property :is_active, Boolean, :default => true
  property :created_at, DateTime
  property :updated_at, DateTime
  has n, :teams
  has n, :players

  def self.team_names
    %w{red blue}
  end

  after :create do
    self.class.team_names.each {|color| teams.create :name => color}
  end

  def pick_team
  	# At this point we can be sure there are already 2 teams in the game since the game
  	# was created in the "/games/:layer_id/join"
  	team = (teams.first.players.count < teams.last.players.count ? teams.first : teams.last)
  end
  
  def total_points
    total_array = self.class.team_names.collect! {|team_name| points_for(team_name)}
    total = 0
    total_array.each {|t| total += t}
    total
  end
  
  def points_for(team)
    points = teams.first(:name => team).players.collect {|player| player.points_cache}
    total = 0
    points.each {|p| total += p}
    total
  end
  
end