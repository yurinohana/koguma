require 'slack-ruby-client'

Slack.configure do |conf|
  # 先ほど控えておいたAPI Tokenをセット
  conf.token = 'xoxb-280709370913-oJJlpq4aa8BAutQnsZiD0Fbs'
end

# RTM Clientのインスタンスを生成
client = Slack::RealTime::Client.new

# hello eventを受け取った時の処理
client.on :hello do
  puts 'connected!'
end

# message eventを受け取った時の処理
client.on :message do |data|
  case data['text']
  when 'にゃーん' then
    # textが 'にゃーん' だったらそのチャンネルに 'Λ__Λ' を投稿
    client.message channel: data['channel'], text:'Λ__Λ'
  end
end

# Slackに接続
client.start!