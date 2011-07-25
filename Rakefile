def init(env=ENV['RACK_ENV']); require File.join('.', 'environment.rb') end

namespace :db do
  task :bootstrap do
    init
    DataMapper.auto_migrate!
  end
  task :migrate do
    init
    DataMapper.auto_upgrade!
  end
end