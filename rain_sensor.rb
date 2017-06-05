require_relative './lib/rain_sensor'
require 'slack-notifier'

SLACK_ACCESS_TOKEN = ENV['SLACK_INCOMING_WEBHOOK']
SLACK_NOTIFY_TO = ENV['SLACK_NOTIFY_TO']
YAHOO_APP_ID = ENV['YAHOO_APP_ID']
LOCATION_COORDINATES = ENV['LOCATION_COORDINATES'] # ex) 139.700306,35.689407
LOCATION_NAME = ENV['LOCATION_NAME'] # 表示用テキスト

#rs = RainSensor.new(coordinates: LOCATION_COORDINATES, yahoo_app_id: YAHOO_APP_ID)
#p rs.result

## todo: method にする
#
#p forecasts
#
## todo: 降り出した
## todo: 今後止む
## todo: 雨がやみました
#
#notifier = Slack::Notifier.new SLACK_ACCESS_TOKEN
#
#notifier.ping text.join("\n"),
#              username: "#{LOCATION_NAME}で雨が降ってるよ", # todo: 状況でかえる．降り出したよ．ふってるよ．やんだよ
#              channel: SLACK_NOTIFY_TO,
#              icon_emoji: ':rain_cloud:'
