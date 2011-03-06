class Browser
  include DataMapper::Resource
  property :id, Serial
  property :jabber_id, String, :length => 255
  property :created_at, DateTime
  property :updated_at, DateTime
end