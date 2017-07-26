require 'json'
require 'net/https'
require 'slack'

CONSUMER_KEY=ENV['POCKET_CONSUMER_KEY']
POCKET_ACCESS_TOKEN=ENV['POCKET_ACCESS_TOKEN']

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

def request(host, path, params = {}, headers = {})
  data = params.map { |k, v| [k, v.to_s.encode('utf-8')] }.to_h
  
  http = Net::HTTP.new(host, 443)
  http.use_ssl = true
  
  req = Net::HTTP::Post.new(path, initheader = headers)
  req.set_form_data(data)
  
  res = http.request(req)
end

headers = {
  'Content-Type' =>'application/json; charset=UTF-8',
  'X-Accept' => 'application/json'
}

params = {:consumer_key => CONSUMER_KEY, :access_token => POCKET_ACCESS_TOKEN, :sort => "newest", :count => 2}
res = request('getpocket.com', '/v3/get', params, headers)

raise "error: cannot get response." unless res.is_a?(Net::HTTPOK)

res_json = JSON.parse(res.body)

unless res_json.has_key?('list')
  exit
end

res_json['list'].each do |id, article|

  # post to slack
  text = "Don't forget this biscuit in Pocket\n" << article['given_url']
  Slack.chat_postMessage(text: text, channel: '#news', as_user: true)

  # archive
  actions = JSON.generate([{ "action" => "archive", "item_id" => id.to_s }])
  params = {:consumer_key => CONSUMER_KEY, :access_token => POCKET_ACCESS_TOKEN, :actions => actions.to_s}
  res = request('getpocket.com', '/v3/send', params, headers)

  sleep(1) # pray
end
