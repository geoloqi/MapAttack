class Player
  include DataMapper::Resource
  property :id, Serial
  property :geoloqi_id, String, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime
  property :points_cache, Integer, :default => 0
  property :profile_image, String, :length => 255
  property :name, String, :length => 255
  property :token, String, :length => 255
  
  has n, :scores
  
  def add_points(points)
    scores.create :points => points
    update :points_cache => (self.points_cache + points.to_i)
    reload
  end
end