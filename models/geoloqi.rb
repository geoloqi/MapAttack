module Geoloqi
  API_URL = 'https://api.geoloqi.com/1/'
  def self.headers(oauth_token); {'Authorization' => "OAuth #{oauth_token}", 'Content-Type' => 'application/json'} end
  def self.post(oauth_token, url, body)
    response = Typhoeus::Request.run API_URL+url,
                                     :method  => :post,
                                     :body => body.to_json,
                                     :headers => Geoloqi.headers(oauth_token)
    puts response.body
    SymbolTable.new JSON.parse(response.body)
  end
  def self.get(oauth_token, url)
    response = Typhoeus::Request.run API_URL+url,
                                     :method  => :get,
                                     :headers => Geoloqi.headers(oauth_token)
    puts response.body
    SymbolTable.new JSON.parse(response.body)
  end
end