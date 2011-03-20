class Team
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime
  belongs_to :game
  has n, :players
end