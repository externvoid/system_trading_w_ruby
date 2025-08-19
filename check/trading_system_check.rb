require "./lib/trading_system"
require "./lib/base"
require "./lib/text_to_stock"

@data = TextToStock.new(stock_list: "tosho_list.txt")
@trading_system =
  TradingSystem.new(entries: EstrangementEntry.new(span: 20, rate: 5),
                    exits:   [StopOutExit.new,
                              EstrangementExit.new(span:20, rate: 3)],
                    stops:   AverageTrueRangeStop.new(span: 20),
                    filters: MovingAverageDirectionFilter.new(span: 30))
    
def simulate(code)
  stock = @data.generate_stock(code)
  @trading_system.set_stock(stock)
  @trading_system.calculate_indicators
  trade = nil
  trades = []
  stock.prices.size.times do |i|
    if trade
      @trading_system.set_stop(trade, i)
      trade.length += 1
    end
    unless trade
      trade = @trading_system.check_entry(i)
      trade.volume = stock.unit if trade
    end
    if trade
      @trading_system.check_exit(trade, i)
      if trade.closed?
        trades << trade
        trade = nil
      end
    end
  end
  trades
end

trades = simulate(8604)
pp trades
puts
trades.each {|trade| puts trade.profit}
puts
puts "総損益 #{trades.map {|trade| trade.profit}.sum}"
