
require "./lib/array"

array = [100, 97, 111, 115, 116, 123, 121, 119, 115, 110]

puts array.sum      #=> 1127
puts array.average  #=> 112.7

p array.moving_average(4)
  #=> [nil, nil, nil, 105.75, 109.75, 116.25, 118.75, 119.75, 119.5, 116.25]
p array.highs(3)
  #=> [nil, nil, 111, 115, 116, 123, 123, 123, 121, 119]
p array.lows(3)
  #=> [nil, nil, 97, 97, 111, 115, 116, 119, 115, 110]

# 3区間高値と安値の中間
middle = array.map_indicator(3) do |vals|
  (vals.max + vals.min) / 2.0
end
p middle
  #=> [nil, nil, 104.0, 106.0, 113.5, 119.0, 119.5, 121.0, 118.0, 114.5]

# 前日との増減
changes = array.map_indicator(2) do |vals|
  vals.last - vals.first
end
p changes
  #=> [nil, -3, 14, 4, 1, 7, -2, -2, -4, -5]

# 3区間の増減の平均
average_changes = changes.moving_average(3)
p average_changes
  #=> [nil, nil, nil, 5.0, 6.333333333333333, 4.0, 2.0, 1.0,  -2.6666666666666665, -3.6666666666666665]

# 指数移動平均（Exponential Moving Average）
span = 4
alpha = 2.0 / (span + 1)
ema = nil
ema_array = array.map_indicator(span) do |vals|
  unless ema
    ema = vals.average
  else
    ema += alpha * (vals.last - ema)
  end
end
p ema_array
  #=> [nil, nil, nil, 105.75, 109.85, 115.11, 117.466, 118.0796, 116.84776, 114.108656]
