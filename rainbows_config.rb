# For production
listen 11000
worker_processes 2
pid 'tmp/rainbows.pid'
Rainbows! do
  use :ThreadSpawn
  worker_connections 200
end
