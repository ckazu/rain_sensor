require 'json'
require 'faraday'

class RainSensor
  def initialize(coordinates:, yahoo_app_id:)
    @coordinates, @yahoo_app_id = coordinates, yahoo_app_id
  end

  def result
    Decorator.new(self).report
  end

  def current_rainfall
    observations.last['Rainfall']
  end

  def recently_rainfall
    observations[-2]['Rainfall']
  end

  def forecast_rainfall_average
    forecasts.inject(0.0) {|sum, w| sum += w['Rainfall'] } / forecasts.size
  end

  def forecast_after_one_hour_rainfall
    forecasts.last['Rainfall']
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
    JSON.parse(response.body).to_h['Feature'][0]['Property']['WeatherList']['Weather']
  end

  def observations
    weather.select {|w| w['Type'] == 'observation' }.sort_by {|o| o['Date'] }
  end

  def forecasts
    weather.select {|w| w['Type'] == 'forecast' }.sort_by {|o| o['Date'] }
  end

  class Decorator
    def initialize(rain_sensor, forecast_delta: 0.2)
      @rs = rain_sensor
      @forecast_delta = forecast_delta
    end

    def report
      recently = @rs.recently_rainfall
      current = @rs.current_rainfall
      forecast = @rs.forecast_rainfall_average
      forecast_after_one_hour = @rs.forecast_after_one_hour_rainfall

      text = []
      text << just_rain(recently, current)
      text << just_sunny(recently, current)
      text << will_rainy(current, forecast)
      text << now_rainfall(current)
      text << forecast(current, forecast)
      text << will_sunny(current, forecast_after_one_hour)

      #text << text_of_will_stop(@rsforecasts.last['Rainfall']) or text_of_prediction(@rs.now, @rs.predict)
      if text.compact.empty?
        nil
      else
        text.compact.join("\n")
      end
    end

    def rainfall_type(rainfall)
      return if rainfall < 0

      case rainfall
      when 0; nil
      when 0...3; '弱い雨'
      when 3...10; '雨'
      when 10...20; 'やや強い雨'
      when 20...30; '強い雨'
      when 30...50; '激しい雨'
      when 50...80; '非常に激しい雨'
      else; '猛烈な雨'
      end
    end

    def just_rain(before, now)
      "雨が降り始めました" if before <= 0.0 && now > 0.0
    end

    def just_sunny(before, now)
      "雨は止みました" if before > 0.0 && now <= 0.0
    end

    def will_rainy(now, forecast)
      "1時間以内に `#{rainfall_type(forecast)}` が降り出しそうです" if now <= 0.0 && forecast > 0.0
    end

    def now_rainfall(rainfall)
      "現在 #{rainfall} mm/h の `#{rainfall_type(rainfall)}` が降っています" if rainfall > 0.0
    end

    def will_sunny(now, forecast)
      "1時間以内には止む見込みです" if now > 0.0 && forecast <= 0.0
    end

    def forecast(now, average_of_forecast)
      return if now <= 0.0
      if ((now - @forecast_delta)..(now + @forecast_delta)).include? average_of_forecast
        "このままの雨がしばらく続くでしょう (#{average_of_forecast.round(2)} mm/h)"
      elsif now < average_of_forecast
        "雨の勢いは次第に強まるでしょう (#{average_of_forecast.round(2)} mm/h)"
      else
        "雨の勢いは次第に弱まるでしょう (#{average_of_forecast.round(2)} mm/h)"
      end
    end
  end
end
