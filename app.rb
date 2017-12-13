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

    if data['user'] != 'U89KG95PD' && data['text'] == 'こんにちは'
      ws.send({
        type: 'message',
        text: "はろー",
        channel: data['channel']
        }.to_json)
    end
  end
  
  ws.on :close do |event|
    p [:close, event.code]
    ws = nil
    EM.stop
  end
  
  EventMachine.add_periodic_timer(60) do
    ws.send "{}"
  end

end