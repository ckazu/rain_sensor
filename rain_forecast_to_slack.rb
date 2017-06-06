require_relative './lib/rain_sensor'
require 'slack-notifier'

SLACK_ACCESS_TOKEN = ENV['SLACK_INCOMING_WEBHOOK']
SLACK_NOTIFY_TO = ENV['SLACK_NOTIFY_TO']
YAHOO_APP_ID = ENV['YAHOO_APP_ID']
LOCATION_COORDINATES = ENV['LOCATION_COORDINATES'] # ex) 139.700306,35.689407
LOCATION_NAME = ENV['LOCATION_NAME'] # 表示用テキスト

rs = RainSensor.new(coordinates: LOCATION_COORDINATES, yahoo_app_id: YAHOO_APP_ID)
result = rs.result
exit unless result

notifier = Slack::Notifier.new SLACK_ACCESS_TOKEN
notifier.ping result,
              username: "#{LOCATION_NAME} の雨模様をお知らせ",
              channel: SLACK_NOTIFY_TO,
              icon_emoji: ':rain_cloud:'
