require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'
require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/koguma.rb'

response = HTTP.post("https://slack.com/api/rtm.start", params: {
    token: ENV['SLACK_API_TOKEN']
  })

rc = JSON.parse(response.body)

url = rc['url']

EM.run do
  # Web Socketインスタンスの立ち上げ
  ws = Faye::WebSocket::Client.new(url)

  ws.on :open do
    p [:open]
  end

  ws.on :message do |event|
    data = JSON.parse(event.data)
    p [:message, data]
    
    Template.each do |temp|
    if data['text'] == temp.input
      ws.send({
        type: 'message',
        text: temp.output,
        channel: data['channel']
        }.to_json)
    end
  end
  end

end