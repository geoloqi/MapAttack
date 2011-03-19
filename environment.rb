case RUBY_VERSION[0..2]
  when '1.8' then $KCODE = "u"
  when '1.9' then Encoding.default_internal = 'UTF-8'
end
require "rubygems"
require "bundler"
Bundler.setup
Bundler.require

class Sinatra::Base
  configure do
    set :root, File.join(File.expand_path(File.join(File.dirname(__FILE__))))
    Dir.glob(File.join(root, 'models', '**/*.rb')).each { |f| require f }
    DataMapper.setup :default, ENV['DATABASE_URL'] || "sqlite3://#{File.join root, 'pdx_pacman.db'}"
    DataMapper.auto_upgrade!
  end
end

require File.join(Sinatra::Base.root, 'pdx_pacman.rb')