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
  # Web Socketインスタンスの立ち上げ
  ws = Faye::WebSocket::Client.new(url)

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

end