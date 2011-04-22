ENV['RACK_ENV'] = 'test'
raise 'Forget it.' if ENV['RACK_ENV'] == 'production'
require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'environment.rb')
require 'eventmachine'
Bundler.require :test
DataMapper.auto_migrate!

describe PdxPacman do
  include Rack::Test::Methods
  
  def app
    PdxPacman
  end
  
  it 'returns join page, create game, and add teams for valid layer' do
    EM.synchrony do
      get '/game/1QY/join'
      EventMachine.stop
    end
    last_response.should be_ok
    last_response.body.should =~ /Join Game/
    Game.count.should == 1
    Game.first.layer_id.should == '1QY'
    Team.count.should == 2
    Team.all(:game => Game.first).length.should == 2
    Team.all(:name => 'red').length.should == 1
    Team.all(:name => 'blue').length.should == 1
  end
end