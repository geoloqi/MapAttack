require "base64"

RestClient.log = STDOUT
module Geoloqi
  class Error < StandardError
    def initialize(type, message=nil)
      type += " - #{message}" if message
      super type
    end
  end
  
  API_URL = 'https://api.geoloqi.com/1/'
  def self.headers(oauth_token)
    {'Authorization' => "OAuth #{oauth_token}", 'Content-Type' => 'application/json'} 
  end
  
  def self.run(meth, oauth_token, url, body=nil)
    args = {:head => headers(oauth_token)}
    args[:body] = body.to_json if body
    response = JSON.parse EM::Synchrony.sync(EventMachine::HttpRequest.new(API_URL+url).send(meth.to_sym, args)).response
    raise Error.new(response['error'], response['error_description']) if response['error']
    
    case response
    when Array
      response.map! {|e| SymbolTable.new e}
    when Hash
      SymbolTable.new response
    end
  end

  def self.post(oauth_token, url, body)
    run :post, oauth_token, url, body
  end
  
  def self.get(oauth_token, url)
    run :get, oauth_token, url
  end
  
  def self.get_token(auth_code, redirect_uri)
    args = {:body => Rack::Utils.escape(:client_id => Geoloqi::CLIENT_ID,
                                        :client_secret => Geoloqi::CLIENT_SECRET,
                                        :code => auth_code,
                                        :grant_type => "authorization_code",
                                        :redirect_uri => redirect_uri)}
    JSON.parse EM::Synchrony.sync(EventMachine::HttpRequest.new(API_URL+"oauth/token").post(args)).response
  end
end
