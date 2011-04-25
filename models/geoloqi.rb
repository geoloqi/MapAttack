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
    puts args.inspect
    response_json = JSON.parse EM::Synchrony.sync(EventMachine::HttpRequest.new(API_URL+url).send(meth.to_sym, args)).response
    raise Error.new(response_json['error'], response_json['error_description']) if response_json['error']
    response_json
  end

  def self.post(oauth_token, url, body)
    obj = run :post, oauth_token, url, body
    case obj
    when Array
      ret = []
      obj.each do |el|
        ret << SymbolTable.new(el)
      end
    when Hash
      ret = SymbolTable.new obj
    end
    ret
  end
  
  def self.get(oauth_token, url)
    obj = run :get, oauth_token, url
    case obj
    when Array
      ret = []
      obj.each do |el|
        ret << SymbolTable.new(el)
      end
    when Hash
      ret = SymbolTable.new obj
    end
    ret
  end
  
  def self.get_token(auth_code, redirect_uri)
    args = {}  # {:head => {'Authorization' => "Basic " + Base64.encode64(Geoloqi::CLIENT_ID + ":" + Geoloqi::CLIENT_SECRET)}}
    args[:body] = Rack::Utils.escape :client_id => Geoloqi::CLIENT_ID,
                                     :client_secret => Geoloqi::CLIENT_SECRET,
                                     :code => auth_code,
                                     :grant_type => "authorization_code",
                                     :redirect_uri => redirect_uri
    response = EM::Synchrony.sync(EventMachine::HttpRequest.new(API_URL+"oauth/token").post(args)).response
    puts "RESPONSE OAUTH: #{response.inspect}"
    response_json = JSON.parse response
    puts response_json.inspect
    response_json
  end
end
