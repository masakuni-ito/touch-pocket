require 'json'
require 'net/https'
require 'cgi'
require 'cgi/session'

cgi =  CGI.new

consumer_key = nil
if cgi.params.has_key?('consumer_key')
  consumer_key = cgi.params['consumer_key'].first.to_s
end

# get request_token
headers = {
  'Content-Type' =>'application/json; charset=UTF-8',
  'X-Accept' => 'application/json'
}

params = {:consumer_key => consumer_key, :redirect_uri => 'http://localhost:8000/authorize'}
data = params.map { |k, v| [k, v.to_s.encode('utf-8')] }.to_h

http = Net::HTTP.new('getpocket.com', 443)
http.use_ssl = true

req = Net::HTTP::Post.new('/v3/oauth/request', initheader = headers)
req.set_form_data(data)

res = http.request(req)

raise "error: cannot get response." unless res.is_a?(Net::HTTPOK)

# get code
res_json = JSON.parse(res.body)

# save code in session
session = CGI::Session.new(cgi)
session['consumer_key'] = consumer_key
session['code'] = res_json['code']

# redirect to pocket authorization
link = URI.escape("https://getpocket.com/auth/authorize?request_token=#{res_json['code']}&redirect_uri=http://localhost:8000/authorize")
print cgi.header({ 
  "status"     => "REDIRECT",
  "Location"   => link
})

