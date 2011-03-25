class Game
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :layer_id, String, :length => 12, :index => true
  property :created_at, DateTime
  property :updated_at, DateTime
  has n, :teams
  has n, :player
end