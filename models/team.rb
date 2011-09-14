class Team
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime
  belongs_to :game
  has n, :players

  def score
    points = self.class.players.collect {|player| player.points_cache}
    total = 0
    points.each {|p| total += p}
    total    
  end
end