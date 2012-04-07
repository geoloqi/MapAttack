class Admin
  include DataMapper::Resource
  property :id, Serial
  property :geoloqi_user_id, String
  has n, :games
end