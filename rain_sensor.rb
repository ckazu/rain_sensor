require 'json'
require 'faraday'
require 'slack-notifier'

SLACK_ACCESS_TOKEN = ENV['SLACK_INCOMING_WEBHOOK']
SLACK_NOTIFY_TO = ENV['SLACK_NOTIFY_TO']
YAHOO_APP_ID = ENV['YAHOO_APP_ID']
LOCATION_COORDINATES = ENV['LOCATION_COORDINATES'] # ex) 139.700306,35.689407
LOCATION_NAME = ENV['LOCATION_NAME'] # 表示用テキスト

# todo: module にする
class RainSensor
  def initialize(coordinates:, yahoo_app_id:)
    @coordinates, @yahoo_app_id = coordinates, yahoo_app_id
  end

  def result_text
    d = Decorator.new(self)
    d.result_text
  end

  def current
    @current ||= observations.sort {|o| o['Date'].to_i }.last
  end

  def current_rainfall
    current['Rainfall']
  end

  def forecast_rainfall
    (forecasts.inject(0.0) {|sum, w| sum += w['Rainfall'].to_f } / forecasts.size).round(2)
  end

  private
  def conn
    @conn ||= Faraday::Connection.new(:url => 'https://map.yahooapis.jp')
  end

  def response
    # todo: error handling
    @response ||= conn.get "/weather/V1/place?output=json&past=1&coordinates=#{@coordinates}&appid=#{@yahoo_app_id}"
  end

  def weather
    @weather ||= JSON.parse(response.body).to_h['Feature'][0]['Property']['WeatherList']['Weather']
  end

  def observations
    @observations ||= weather.select {|w| w['Type'] == 'observation' }
  end

  def forecasts
    @forecasts ||= weather.select {|w| w['Type'] == 'forecast' }
  end

  class Decorator
    def initialize(rain_sensor)
      @rs = rain_sensor
      @forecast_delta = 0.2
    end

    def result_text
      text = []
      text << will_rainy(@rs.forecast_rainfall)
      text << now(@rs.current_rainfall)
      text << will_sunny(@rs.forecast_rainfall)

      #text << text_of_will_stop(@rsforecasts.last['Rainfall']) or text_of_prediction(@rs.now, @rs.predict)
      text.join("\n")
    end

    def rainfall_type(rainfall)
      case rainfall
      when   0.0...3.0; '弱い雨'
      when  3.0...10.0; '雨'
      when 10.0...20.0; 'やや強い雨'
      when 20.0...30.0; '強い雨'
      when 30.0...50.0; '激しい雨'
      when 50.0...80.0; '非常に激しい雨'
      else; '猛烈な雨'
      end
    end

    def will_rainy(rainfall)
      return if rainfall <= 0.0
      "1時間以内に `#{rainfall_type(rainfall)}` が降り出しそうです"
    end

    def now(rainfall)
      return if rainfall <= 0.0
      "現在 #{rainfall} mm/h の `#{rainfall_type(rainfall)}` が降っています"
    end

    def text_of_prediction(now, predict)
      if ((now - @forecast_delta)..(now + @forecast-delta)).include? predict
        "このままの雨がしばらく続くでしょう (#{predict} mm/h)"
      elsif now < predict
        "雨の勢いは次第に強まるでしょう (#{predict} mm/h)"
      else
        "雨の勢いは次第に弱まるでしょう (#{predict} mm/h)"
      end
    end

    def will_sunny(predict)
      "雨は次第に弱まり，1時間以内に止むでしょう" if predict == 0.0
    end

  end
end

rs = RainSensor.new(coordinates: LOCATION_COORDINATES, yahoo_app_id: YAHOO_APP_ID)
p rs.result_text

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
