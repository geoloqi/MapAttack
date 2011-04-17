ENV['RACK_ENV'] = 'test'
raise 'Forget it.' if ENV['RACK_ENV'] == 'production'

require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'environment.rb')
require 'test/unit'
require 'eventmachine'
Bundler.require :test
DataMapper.auto_migrate!

class Test::Unit::TestCase
  include Rack::Test::Methods
  def mock_app(base=Sinatra::Base, &block)
    @app = Sinatra.new base, &block
  end
  def app; @app end
  def app=(new_app); @app = new_app end
end

class ControllerTests < Test::Unit::TestCase
  def app
    PdxPacman
  end

  context "a game" do
    test "loads the join page" do
      get 'game/test/join'
      assert last_response.ok?
      assert last_response.body =~ /Join Game/
    end
  end
end