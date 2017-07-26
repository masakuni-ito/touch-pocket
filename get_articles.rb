require 'json'
require 'net/https'

CONSUMER_KEY=ENV['POCKET_CONSUMER_KEY']
POCKET_ACCESS_TOKEN=ENV['POCKET_ACCESS_TOKEN']

headers = {
  'Content-Type' =>'application/json; charset=UTF-8',
  'X-Accept' => 'application/json'
}

params = {:consumer_key => CONSUMER_KEY, :access_token => POCKET_ACCESS_TOKEN, :sort => "newest", :count => 2}
data = params.map { |k, v| [k, v.to_s.encode('utf-8')] }.to_h

http = Net::HTTP.new('getpocket.com', 443)
http.use_ssl = true

req = Net::HTTP::Post.new('/v3/get', initheader = headers)
req.set_form_data(data)

res = http.request(req)

raise "error: cannot get response." unless res.is_a?(Net::HTTPOK)

res_json = JSON.parse(res.body)

puts JSON.pretty_generate(res_json)

