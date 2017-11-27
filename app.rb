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

  #  接続が確立した時の処理
  ws.on :open do
    p [:open]
  end

  ws.on :message do |event|
    data = JSON.parse(event.data)
    p [:message, data]

    if data['text'] == 'こんにちは'
      ws.send({
        type: 'message',
        text: "こんにちは <@#{data['user']}> さん",
        channel: data['channel']
        }.to_json)
    end
  end

  ws.on :close do
    p [:close, event.code]
    ws = nil
    EM.stop
  end

end