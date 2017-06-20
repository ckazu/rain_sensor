require_relative '../lib/rain_sensor.rb'
require 'minitest/autorun'
require 'minitest/color'
require 'minitest/power_assert'

class RainSensorTest < Minitest::Test
  def test_result
    File.open('tmp/state.dat', 'w')
    rs = RainSensor.new(coordinates: Object, yahoo_app_id: Object)

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>0.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>0.2},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>0.1},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>0.3}] do
      assert { rs.result == "1時間以内に `弱い雨` が降り出しそうです" }
    end

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>12.0}] do
      assert { rs.result == "雨が降り始めました\n現在 12.0 mm/h の `やや強い雨` が降っています" }
    end

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>8.0},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>6.0}] do
      assert { rs.result == "雨が降り始めました\n現在 12.0 mm/h の `やや強い雨` が降っています\n雨の勢いは次第に弱まる:arrow_lower_right:でしょう (8.67 mm/h)" }
    end

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>14.0},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>16.0}] do
      assert { rs.result == "雨が降り始めました\n現在 12.0 mm/h の `やや強い雨` が降っています\n雨の勢いは次第に強まる:arrow_upper_right:でしょう (14.0 mm/h)" }
    end

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>8.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>8.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>1.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>0.0},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>0.0}] do
      assert { rs.result == "雨が降り始めました\n現在 12.0 mm/h の `やや強い雨` が降っています\n雨の勢いは次第に弱まる:arrow_lower_right:でしょう (3.4 mm/h)" }
    end

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>8.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>8.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>0.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>0.0},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>0.0}] do
      assert { rs.result == "雨が降り始めました\n現在 12.0 mm/h の `やや強い雨` が降っています\n雨の勢いは次第に弱まる:arrow_lower_right:でしょう (3.2 mm/h)\n1時間以内には止む見込みです" }
    end

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>12.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>12.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>12.0}] do
      assert { rs.result == "現在 12.0 mm/h の `やや強い雨` が降っています" }
    end

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>20.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>12.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>0.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>0.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>0.0},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>0.0}] do
      assert { rs.result == ":barely_sunny: 雨は止みました" }
    end

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>20.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>12.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>0.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>0.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>100.0},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>0.0}] do
      assert { rs.result == ":barely_sunny: 雨は止みました\n1時間以内に `激しい雨` が降り出しそうです" }
    end

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>0.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>0.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>0.0},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>0.0}] do
      assert { rs.result == nil }
    end
  end

  def test_state
    File.open('tmp/state.dat', 'w')
    rs = RainSensor.new(coordinates: Object, yahoo_app_id: Object)

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>12.0}] do
      assert { rs.result == "雨が降り始めました\n現在 12.0 mm/h の `やや強い雨` が降っています" }
    end

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>12.0}] do
      assert { rs.result == nil }
    end

    rs.stub :weather,
            [{"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>0.0},
             {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>12.0},
             {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>12.0}] do
      assert { rs.result == nil }
    end
  end

  def test_current_rainfall
    rs = RainSensor.new(coordinates: Object, yahoo_app_id: Object)
    res = [
      {"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>12.0},
      {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>9.0},
      {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>11.0},
      {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>11.75},
    ]
    rs.stub :weather, res do
      assert { rs.current_rainfall == 9.0 }
    end
  end

  def test_recently_rainfall
    rs = RainSensor.new(coordinates: Object, yahoo_app_id: Object)
    res = [
      {"Type"=>"observation", "Date"=>"201706051855", "Rainfall"=>12.0},
      {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>9.0},
      {"Type"=>"observation", "Date"=>"201706051905", "Rainfall"=>11.0},
      {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>11.75},
    ]
    rs.stub :weather, res do
      assert { rs.recently_rainfall == 11.0 }
    end
  end

  def test_forecast_rainfall
    rs = RainSensor.new(coordinates: Object, yahoo_app_id: Object)
    res = [
      {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>9.0},
      {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>1.01},
      {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>2.01},
      {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>2.01},
      {"Type"=>"forecast", "Date"=>"201706051955", "Rainfall"=>0.0},
      {"Type"=>"forecast", "Date"=>"201706052005", "Rainfall"=>5.01}
    ]
    rs.stub :weather, res do
      assert { rs.forecast_rainfall_average == 2.008 }
    end
  end

  def test_forecast_after_one_hour_rainfall
    rs = RainSensor.new(coordinates: Object, yahoo_app_id: Object)
    res = [
      {"Type"=>"observation", "Date"=>"201706051915", "Rainfall"=>9.0},
      {"Type"=>"forecast", "Date"=>"201706051925", "Rainfall"=>1.01},
      {"Type"=>"forecast", "Date"=>"201706051935", "Rainfall"=>2.01},
      {"Type"=>"forecast", "Date"=>"201706052005", "Rainfall"=>5.01},
      {"Type"=>"forecast", "Date"=>"201706051955", "Rainfall"=>0.0},
      {"Type"=>"forecast", "Date"=>"201706051945", "Rainfall"=>2.01}
    ]
    rs.stub :weather, res do
      assert { rs.forecast_after_one_hour_rainfall == 5.01 }
    end
  end
end

class RainSensorDecoratorTest < Minitest::Test
  def test_rainfall_type
    rsd = RainSensor::Decorator.new(Object)
    assert { rsd.rainfall_type(0) == nil }
    assert { rsd.rainfall_type(0.0) == nil }
    assert { rsd.rainfall_type(0.01) == '弱い雨' }
    assert { rsd.rainfall_type(2.999) == '弱い雨' }
    assert { rsd.rainfall_type(3) == '雨' }
    assert { rsd.rainfall_type(79.99999) == '非常に激しい雨' }
    assert { rsd.rainfall_type(80.0) == '猛烈な雨' }
    assert { rsd.rainfall_type(-1) == nil }
  end

  def test_just_rain
    rsd = RainSensor::Decorator.new(Object)
    assert { rsd.just_rain(0, 0) == nil }
    assert { rsd.just_rain(0, 10) == "雨が降り始めました" }
    assert { rsd.just_rain(10, 0) == nil }
    assert { rsd.just_rain(10, 10) == nil }
  end

  def test_will_rainy
    rsd = RainSensor::Decorator.new(Object)
    assert { rsd.will_rainy(0, -0.1) == nil }
    assert { rsd.will_rainy(0, 0) == nil }
    assert { rsd.will_rainy(1, 0) == nil }
    assert { rsd.will_rainy(1, 30) == nil }
    assert { rsd.will_rainy(0, 30) == "1時間以内に `激しい雨` が降り出しそうです" }
  end

  def test_now_rainfall
    rsd = RainSensor::Decorator.new(Object)
    assert { rsd.now_rainfall(-0.1) == nil }
    assert { rsd.now_rainfall(0) == nil }
    assert { rsd.now_rainfall(49.99) == "現在 49.99 mm/h の `激しい雨` が降っています" }
  end

  def test_will_sunny
    rsd = RainSensor::Decorator.new(Object)
    assert { rsd.will_sunny(0, 0) == nil }
    assert { rsd.will_sunny(0, 123) == nil }
    assert { rsd.will_sunny(10, 0) == "1時間以内には止む見込みです" }
    assert { rsd.will_sunny(10, 123) == nil }
  end

  def test_just_sunny
    rsd = RainSensor::Decorator.new(Object)
    assert { rsd.just_sunny(0, 0) == nil }
    assert { rsd.just_sunny(0, 10) == nil }
    assert { rsd.just_sunny(10, 0) == ":barely_sunny: 雨は止みました" }
    assert { rsd.just_sunny(10, 10) == nil }
  end

  def test_forecast
    rsd = RainSensor::Decorator.new(Object, forecast_delta: 1.0)
    assert { rsd.forecast_message(0.0, 10) == nil }
    assert { rsd.forecast_message(10.0, 8.999) == "雨の勢いは次第に弱まる:arrow_lower_right:でしょう (9.0 mm/h)" }
    assert { rsd.forecast_message(10.0, 9) == nil } # "このままの雨がしばらく続くでしょう (9.0 mm/h)" }
    assert { rsd.forecast_message(10.0, 10.999) == nil } # "このままの雨がしばらく続くでしょう (11.0 mm/h)" }
    assert { rsd.forecast_message(10.0, 11.0) == nil } # "このままの雨がしばらく続くでしょう (11.0 mm/h)" }
    assert { rsd.forecast_message(10.0, 11.00001) == "雨の勢いは次第に強まる:arrow_upper_right:でしょう (11.0 mm/h)" }
    assert { rsd.forecast_message(10.0, 11.005) == "雨の勢いは次第に強まる:arrow_upper_right:でしょう (11.01 mm/h)" }
  end
end
