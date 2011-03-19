ENV['RACK_ENV'] = 'test'
raise 'Forget it.' if ENV['RACK_ENV'] == 'production'

require File.join(File.expand_path(File.dirname(__FILE__)), '..', 'environment.rb')
require 'test/unit'
Bundler.require :test

class Test::Unit::TestCase
  include Rack::Test::Methods
  def mock_app(base=Sinatra::Base, &block); @app = Sinatra.new(base, &block) end
  def app; @app end
  def app=(new_app); @app = new_app end
end

class ControllerTests < Test::Unit::TestCase
  def app
    PdxPacman
  end

  context 'the index' do
    test 'loads correctly' do
      get '/'
      assert last_response.ok?
      assert last_response.body.length > 0
    end
  end
end