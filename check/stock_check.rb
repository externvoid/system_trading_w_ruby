# coding: Windows-31J

require "./lib/stock"

stock = Stock.new(8604, :t, 100)
puts stock.code     #=> 8604
puts stock.market   #=> t
puts stock.unit     #=> 100
puts

stock.add_price("2011-07-01", 402, 402, 395, 397, 17495700)
stock.add_price("2011-07-04", 402, 404, 400, 403, 18819300)
stock.add_price("2011-07-05", 402, 408, 399, 401, 20678000)

puts stock.prices[0][:date]   #=> "2011-07-01"
puts stock.prices[1][:open]   #=> 402
puts stock.prices[2][:high]   #=> 408
p stock.prices

puts
dates = stock.map_prices(:date)       # 日付の配列を取り出す
puts dates[1]                         #=> "2011-07-04"
open_prices = stock.map_prices(:open) # 始値の配列を取り出す
puts open_prices[0]                   #=> 402
p dates       #=> ["2011-07-01", "2011-07-04", "2011-07-05"]
puts

puts stock.dates[0]          #=> "2011-07-01"
puts stock.open_prices[1]    #=> 402
puts stock.high_prices[2]    #=> 408
puts stock.low_prices[0]     #=> 395
puts stock.close_prices[1]   #=> 403
puts stock.volumes[2]        #=> 20678000
