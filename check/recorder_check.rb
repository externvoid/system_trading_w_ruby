# coding: Windows-31J

require "./lib/trading_system"
require "./lib/recorder"
require "./lib/base"
require "./lib/text_to_stock"
require "pp"

@data = TextToStock.new(stock_list: "tosho_list.txt")
@trading_system =
  TradingSystem.new(entries:  EstrangementEntry.new(span: 20, rate: 5),
                    exits:    [StopOutExit.new,
                               EstrangementExit.new(span:20, rate: 3)],
                    stops:    AverageTrueRangeStop.new(span: 20),
                    filters:  MovingAverageDirectionFilter.new(span: 30))

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

recorder = Recorder.new
recorder.record_dir = "result/test"
recorder.create_record_folder
recorder.record_setting(__FILE__)

results = [4063, 7203, 8604].map do |code|
    simulate(code)
  end

results = results.reject {|trades| trades.empty?}

results.each do|trades|
  recorder.record_a_stock(trades)
end
recorder.record_stats_for_each_stock(results)
recorder.record_stats(results)
