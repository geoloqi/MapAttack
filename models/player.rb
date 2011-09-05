class Player
  include DataMapper::Resource
  property :id, Serial
  property :access_token, String, :length => 255, :index => true
  property :geoloqi_user_id, String, :length => 12, :index => true
  property :points_cache, Integer, :default => 0
  property :profile_image, String, :length => 255
  property :name, String
  property :email, String, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime, :index => true
  belongs_to :team
  belongs_to :game
  has n, :scores

  def add_points(points)
    scores.create :points => points
    update :points_cache => (self.points_cache + points.to_i)
    reload
  end
end
