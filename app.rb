require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/koguma.rb'
require './models/tencho.rb'
require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'

response = HTTP.post("https://slack.com/api/rtm.start", params: {
    token: ENV['SLACK_API_TOKEN']
  })

rc = JSON.parse(response.body)

url = rc['url']

EM.run do
  ws = Faye::WebSocket::Client.new(url)

  ws.on :open do
    p [:open]
  end

  ws.on :message do |event|
    data = JSON.parse(event.data)
    p [:message, data]
    @input = Dialogue.where(input: data['text']).sample
    if data['user'] != 'U89KG95PD' && @input
      ws.send({
        type: 'message',
        text: @input.output,
        channel: data['channel']
        }.to_json)
    elsif data['user'] != 'U89KG95PD' && data['text']
        ws.send({
        type: 'message',
        text: Template.pluck(:temp).sample,
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