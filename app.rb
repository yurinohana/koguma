require 'bundler/setup'
Bundler.require
require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'
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

  ws.on :message do |event|
    data = JSON.parse(event.data)
    p [:message, data]

    if data['text'] == 'こんばんは'
      ws.send({
        type: 'message',
        text: "こんばんは <@#{data['user']}> さん",
        channel: data['channel']
        }.to_json)
    end
  end

end