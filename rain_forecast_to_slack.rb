require_relative './lib/rain_sensor'
require 'slack-notifier'

SLACK_ACCESS_TOKEN = ENV['SLACK_INCOMING_WEBHOOK']
SLACK_NOTIFY_TO = ENV['SLACK_NOTIFY_TO']
SLACK_ERROR_NOTIFY_TO = ENV['SLACK_ERROR_NOTIFY_TO']
YAHOO_APP_ID = ENV['YAHOO_APP_ID']
LOCATION_COORDINATES = ENV['LOCATION_COORDINATES'] # ex) 139.700306,35.689407
LOCATION_NAME = ENV['LOCATION_NAME'] # 表示用テキスト

def send_to_slack(access_token, text, opts)
  notifier = Slack::Notifier.new(access_token)
  notifier.ping(text, opts)
end

begin
  rs = RainSensor.new(coordinates: LOCATION_COORDINATES, yahoo_app_id: YAHOO_APP_ID)
  result = rs.result(forecast_delta: 2.50)

  unless result
    $stdout.puts "It is not raining at #{LOCATION_NAME}."
    exit
  end

  $stdout.puts "#{result}\n at #{LOCATION_NAME}."
  send_to_slack SLACK_ACCESS_TOKEN,
                result,
                {
                  username: "#{LOCATION_NAME} の雨模様をお知らせ",
                  channel: SLACK_NOTIFY_TO,
                  icon_emoji: ':rain_cloud:'
                }
rescue => e
  $stderr.puts e

  if SLACK_ERROR_NOTIFY_TO
    send_to_slack SLACK_ACCESS_TOKEN,
                  e.inspect,
                  { channel: SLACK_ERROR_NOTIFY_TO }
  end
end
