require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/koguma.rb'
require './models/tencho.rb'
require 'http'
require 'json'
require 'eventmachine'
require 'faye/websocket'

@dialogues = Dialogue.all

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
    @output = Array.new
    data = JSON.parse(event.data)
    p [:message, data]
    if data['user'] != 'U89KG95PD' && data['text']
    @dialogues.each do |dia|
      if data['text'] =~ /#{dia.input}/
        @output.push(dia.output)
      end
    end
    # @input = Dialogue.where("input like '#{data['text']}'").sample
    # @input = Dialogue.where(input: data['text']).sample
    if data['user'] != 'U89KG95PD' && !@output.empty?
      ws.send({
        type: 'message',
        text: @output.sample,
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