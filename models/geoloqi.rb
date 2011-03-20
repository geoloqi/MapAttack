module Geoloqi
  def self.headers(oauth_token)
    {'Authorization' => "OAuth #{oauth_token}",
     'Content-Type' => 'application/json'}
  end

  API_URL = 'https://api.geoloqi.com/1/'

  def self.send(oauth_token, url, body)
    JSON.parse Typhoeus::Request.run(API_URL + url,
                                     :method  => :post,
                                     :body    => body.to_json,
                                     :headers => Geoloqi.headers(oauth_token)).body
  end

  class Place
    def self.list(layer_id)
      Typhoeus::Request.run("https://api.geoloqi.com/1/place/list",
                            :body => {:layer_id => layer_id}.to_json,
                            :method => :post,
                            :headers => Geoloqi.headers).body
    end

    def self.update
      # TODO: ADD IN TEAM AND PLAYER TO EXTRA JSON
      # team_id  and user_id
      # two teams only
      Typhoeus::Request.run("https://api.geoloqi.com/1/place/update/#{place_id}",
                            :body    => {:extra => {:active => 0}}.to_json,
                            :method  => :post,
                            :headers => Geoloqi.headers).body
    end
  end
end