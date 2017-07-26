require 'json'
require 'net/https'
require 'cgi'
require 'cgi/session'

cgi = CGI.new
session = CGI::Session.new(cgi)

headers = {
  'Content-Type' =>'application/json; charset=UTF-8',
  'X-Accept' => 'application/json'
}

params = {:consumer_key => session['consumer_key'], :code => session['code']}
data = params.map { |k, v| [k, v.to_s.encode('utf-8')] }.to_h

http = Net::HTTP.new('getpocket.com', 443)
http.use_ssl = true

req = Net::HTTP::Post.new('/v3/oauth/authorize', initheader = headers)
req.set_form_data(data)

res = http.request(req)

raise "error: cannot get response." unless res.is_a?(Net::HTTPOK)

# show acces_code
res_json = JSON.parse(res.body)
cgi.out(:type => 'text/plain', :charset => 'UTF-8') {
  "access_token: " << res_json['access_token']
}

