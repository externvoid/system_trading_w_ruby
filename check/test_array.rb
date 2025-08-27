require 'test/unit'
require './lib/array'

class TestArray < Test::Unit::TestCase
  def test_sum
    array = [100, 97, 111, 115, 116, 123, 121, 119, 115, 110]
    puts array.sum      #=> 1127
    assert_equal array.sum, 1127
    puts array.average  #=> 112.7

    p array.moving_average(4)
      #=> [nil, nil, nil, 105.75, 109.75, 116.25, 118.75, 119.75, 119.5, 116.25]
    p array.highs(3)
      #=> [nil, nil, 111, 115, 116, 123, 123, 123, 121, 119]
    p array.lows(3)
  end


end
# [Ruby標準のテスティングフレームワークで手軽にテストコードを書く方法 #RSpec - Qiita](https://qiita.com/jnchito/items/ff4f7a23addbd8dbc460)
