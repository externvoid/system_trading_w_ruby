
require "./lib/base"
require "./lib/text_to_stock"

tts = TextToStock.new(stock_list: "tosho_list.txt")
stock = tts.generate_stock(8604)

est_entry = EstrangementEntry.new(span: 20, rate: 5)
est_entry.stock = stock
est_entry.calculate_indicators

# 以下のデータは、2010/01/04 2010/06/14のもの
real_signals = [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
nil,nil,nil,nil,nil,nil,nil,nil,:long,nil,:long,:long,:long,
:long,:long,:long,:long,:long,:long,nil,nil,nil,nil,nil,nil,
nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
nil,nil,nil,nil,nil,nil,:short,:short,nil,nil,nil,nil,nil,
nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
nil,nil,:long,:long,:long,:long,:long,:long,:long,:long,
:long,:long,:long,:long,:long,:long,:long,:long,:long,nil,
nil,nil,nil,nil,:long,:long,:long,:long,nil,nil]

real_signals.each_with_index do |real_signal, i|
  trade = est_entry.check_long_entry(i + 1) ||
          est_entry.check_short_entry(i + 1)
  signal = trade && trade.trade_type
  puts "#{signal || 'nil'}  #{real_signal || 'nil'}"
  puts "fail in data #{i}\n" unless real_signal == signal
end

puts 
p est_entry.check_long_entry(0)   #=> nil
p est_entry.check_short_entry(0)  #=> nil
