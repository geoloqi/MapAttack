class Player
  include DataMapper::Resource
  property :id, Serial
  property :geoloqi_id, String, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime
  property :points_cache, Integer, :default => 0
  
  has n, :scores
  
  def add_points(points)
    scores.create :points => points
    update :points_cache => (self.points_cache + points)
    reload
  end
end