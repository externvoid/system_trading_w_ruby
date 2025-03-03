
require "./lib/trade"

trade = Trade.new(stock_code:  8604,
                  trade_type:  :long,
                  entry_date:  "2011/11/14",
                  entry_price: 251,
                  entry_time:  :open,
                  volume:      100)

puts trade.stock_code  #=> 8604
puts trade.entry_date  #=> "2011/11/14"
puts trade.entry_price #=> 251
puts trade.long?       #=> true
puts trade.short?      #=> false
puts trade.closed?     #=> false

trade.first_stop = 241
trade.stop       = 241
trade.length     = 1

puts trade.first_stop #=> 241
puts trade.stop       #=> 241
puts trade.r          #=> 10
puts trade.length     #=> 1

trade.length += 1

puts trade.length     #=> 2

trade.exit(date: "2011/11/15",
           price: 255,
           time:  :in_session)

puts trade.closed?           #=> true
puts trade.exit_date         #=> "2011/11/15"
puts trade.profit            #=> 400
puts trade.percentage_result #=> 1.593625498007968
puts trade.r_multiple        #=> 0.4
