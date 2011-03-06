class Score
  include DataMapper::Resource
  property :id, Serial
  property :player_id, Integer
  property :points, Integer
  property :created_at, DateTime
  property :updated_at, DateTime
  
  belongs_to :player
end