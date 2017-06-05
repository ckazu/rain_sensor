require 'json'
require 'faraday'
require 'slack-notifier'

SLACK_ACCESS_TOKEN = ENV['SLACK_INCOMING_WEBHOOK']
SLACK_NOTIFY_TO = ENV['SLACK_NOTIFY_TO']
YAHOO_APP_ID = ENV['YAHOO_APP_ID']
LOCATION_COORDINATES = ENV['LOCATION_COORDINATES'] # ex) 139.700306,35.689407
LOCATION_NAME = ENV['LOCATION_NAME'] # 表示用テキスト

# todo: まとめて module にする
def comment_of(rainfall)
  case rainfall
  when   0.0..3.0; '弱い雨'
  when  3.0..10.0; '雨'
  when 10.0..20.0; 'やや強い雨'
  when 20.0..30.0; '強い雨'
  when 30.0..50.0; '激しい雨'
  when 50.0..80.0; '非常に激しい雨'
  else; '猛烈な雨'
  end
end

conn = Faraday::Connection.new(:url => 'https://map.yahooapis.jp')
response = conn.get "/weather/V1/place?output=json&past=1&coordinates=#{LOCATION_COORDINATES}&appid=#{YAHOO_APP_ID}&"
weather = JSON.parse(response.body).to_h['Feature'][0]['Property']['WeatherList']['Weather']

observations = weather.select {|w| w['Type'] == 'observation' }
forecasts =  weather.select {|w| w['Type'] == 'forecast' }

now = observations.last['Rainfall']
predict = (forecasts.inject(0.0) {|sum, w| sum += w['Rainfall'].to_f } / forecasts.size).round(2)

# todo: method にする
text = %Q|
現在 #{now} mm/h の `#{comment_of(now)}` が降っています
#{(now < predict) ? "このまま雨の勢いは増すでしょう (#{predict} mm/h)" : "今後，雨の勢いは衰えるでしょう (#{predict} mm/h)\n"}
|

# todo: 降り出した
# todo: 今後止む
# todo: 雨がやみました

notifier = Slack::Notifier.new SLACK_ACCESS_TOKEN

notifier.ping text,
              username: "#{LOCATION_NAME}で雨が降ってるよ", # todo: 状況でかえる．降り出したよ．ふってるよ．やんだよ
              channel: SLACK_NOTIFY_TO,
              icon_emoji: ':rain_cloud:'
