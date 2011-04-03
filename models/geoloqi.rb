module Geoloqi
  API_URL = 'https://api.geoloqi.com/1/'
  def self.headers(oauth_token); {'Authorization' => "OAuth #{oauth_token}", 'Content-Type' => 'application/json'} end
  
  def self.run(meth, oauth_token, url, payload='')
    JSON.parse RestClient::Request.execute(:method => meth.to_sym, :url => API_URL+url, :headers => headers(oauth_token), :payload => (payload == '' ? '' : payload.to_json))
  end
  
  def self.post(oauth_token, url, payload)
    obj = run :post, oauth_token, url, payload
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
