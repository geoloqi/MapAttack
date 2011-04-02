module Geoloqi
  API_URL = 'https://api.geoloqi.com/1/'
  def self.headers(oauth_token); {'Authorization' => "OAuth #{oauth_token}", 'Content-Type' => 'application/json'} end
  
  def self.run(meth, oauth_token, url, body=nil)
    args = {:method => meth.to_sym, :url => API_URL+url, :headers => headers(oauth_token)}
    args.merge!(:body => body.to_json) if body
    JSON.response RestClient::Request.execute(args)
  end
  
  def self.post(oauth_token, url, body)
    response = run :post, oauth_token, url, body
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
    response = run :get, oauth_token, url
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