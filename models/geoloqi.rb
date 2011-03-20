module Geoloqi
  API_URL = 'https://api.geoloqi.com/1/'
  def self.headers(oauth_token); {'Authorization' => "OAuth #{oauth_token}", 'Content-Type' => 'application/json'} end
  def self.post(oauth_token, url, body)
    SymbolTable.new JSON.parse(Typhoeus::Request.run(API_URL + url,
                                                     :method  => :post,
                                                     :body    => body.to_json,
                                                     :headers => Geoloqi.headers(oauth_token))).body
  end
end