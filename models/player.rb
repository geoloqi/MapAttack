class Player
  include DataMapper::Resource
  property :id, Serial
  property :geoloqi_id, String, :length => 12, :index => true
  property :points_cache, Integer, :default => 0
  property :profile_image, String
  property :name, String
  property :token, String
  property :created_at, DateTime
  property :updated_at, DateTime
  belongs_to :team
  has n, :scores

  def add_points(points)
    scores.create :points => points
    update :points_cache => (self.points_cache + points.to_i)
    reload
  end
end