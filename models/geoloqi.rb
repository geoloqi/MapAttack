RestClient.log = STDOUT
module Geoloqi
  API_URL = 'https://api.geoloqi.com/1/'
  def self.headers(oauth_token); {'Authorization' => "OAuth #{oauth_token}", 'Content-Type' => 'application/json'} end
  
  def self.run(meth, oauth_token, url, body=nil)
    args = {:head => headers(oauth_token)}
    args[:body] = body.to_json if body
    JSON.parse EM::Synchrony.sync(EventMachine::HttpRequest.new(API_URL+url).send(meth.to_sym, args)).response
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
end
