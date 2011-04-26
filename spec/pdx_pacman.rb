require File.dirname(__FILE__) + '/spec_helper'

describe PdxPacman do
  include WebMock::API
  include Rack::Test::Methods

  def app
    PdxPacman
  end

  it 'returns join page, create game, and add teams for valid layer' do
    EM.synchrony do
=begin
      stub_request(:post, "https://api.geoloqi.com/1/oauth/token").with(:body => {:client_id=>"client_id1234",
                                                                                  :client_secret=>"client_secret1234",
                                                                                  :code=>"1234",
                                                                                  :grant_type=>"authorization_code",
                                                                                  :redirect_uri=>"http://mapattack.org/game/1QY/join"}).to_return('lol')
=end

    stub_request(:post, "https://api.geoloqi.com/1/oauth/token").
      with(:body => Rack::Utils.escape(:client_id => "client_id1234",
                                       :client_secret => "client_secret1234",
                                       :code => "1234",
                                       :grant_type => "authorization_code",
                                       :redirect_uri => "http://mapattack.org/game/1QY/join")).
      to_return(:status => 200,
                :headers => {:content_type => 'application/json'},
                :body => {:access_token => 'access_token1234',
                                    :scope => nil,
                                    :expires_in => '86400',
                                    :refresh_token => 'refresh_token1234'}.to_json)

    stub_request(:get, "https://api.geoloqi.com/1/layer/info/1QY").
      with(:body => '').
      to_return(:status => 200,
                :headers => {},
                :body => {:layer_id => '1QY',
                          :type => 'normal',
                          :name => 'name',
                          :description => 'description',
                          :icon => 'http://localhost/test.png',
                          :public => '1',
                          :url => 'https://a.geoloqi.com/oauth/authorize?response_type=code&client_id=7bcd478f26bd14b1fed18e9fe59e506f&redirect_uri=http%3A%2F%2Fmapattack.org%2Fgame%2F1Lx%2Fjoin',
                          :subscription => {'subscribed' => '0', 'date_subscribed' => '2011-01-01 01:01:01'},
                          :settings => []}.to_json)

    stub_request(:get, "https://api.geoloqi.com/1/account/profile").
      with(:body => '',
           :headers => {:authorization => 'OAuth access_token1234', :content_type => 'application/json'}).
      to_return(:status => 200,
                :body => {:user_id => 'user_id1234', :email => 'e@mail.com1234', :profile_image => 'http://localhost/test.png'}.to_json)

   stub_request(:post, "https://api.geoloqi.com/1/link/create").
     with(:body => {:description => 'Created for name', :minutes => 240}.to_json,
          :headers => {'Authorization'=>'OAuth access_token1234', 'Content-Type'=>'application/json'}).
     to_return(:status => 200, :body => {:link => 'http://geoloqi.com/name/token12',
                                         :shortlink => 'http://loqi.me/token12',
                                         :token => 'token12'}.to_json)

   stub_request(:get, "https://api.geoloqi.com/1/layer/subscribe/1QY").
     with(:headers => {'Authorization'=>'OAuth access_token1234', 'Content-Type'=>'application/json'}).
     to_return(:status => 200, :body => {:layer_id => '1QY',:subscribed => 1}.to_json)

    stub_request(:post, "https://api.geoloqi.com/1/message/send").
             with(:body => {:user_id => 'user_id1234', :text => "You're on the blue team!"}.to_json,
                  :headers => {:authorization => 'OAuth oauth1234', :content_type => 'application/json'}).
             to_return(:status => 200, :body => {:result => 'ok', :username => 'username1234', :user_id => 'user_id1234'}.to_json)

    get '/game/1QY/join?code=1234'
      EventMachine.stop
    end
    last_response.should be_redirect
    last_response.headers['Location'].should == 'http://example.org/game/1QY'
    Game.count.should == 1
    Game.first.layer_id.should == '1QY'
    Team.count.should == 2
    Team.all(:game => Game.first).length.should == 2
    Team.all(:name => 'red').length.should == 1
    Team.all(:name => 'blue').length.should == 1
  end
=begin
  it 'joins a player to the game' do
    EM.synchrony do
      post '/game/1QY/join.json', :oauth_token => 'xwiwcvu'
       #, :content_type => 'application/json'
      EventMachine.stop
    end
    last_response.should be_ok
  end
=end
end
