require_relative '../rain_sensor.rb'
require 'minitest/autorun'
require 'minitest/color'
require 'minitest/power_assert'

class RainSensorDecoratorTest < Minitest::Test
  def test_will_rainy
    rs = RainSensor::Decorator.new(Object)
    assert { nil == rs.will_rainy(0.0) }
  end
end
