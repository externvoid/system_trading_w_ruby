# coding: Windows-31J

require "./lib/base"
require "./lib/text_to_stock"

tts = TextToStock.new(stock_list: "tosho_list.txt")
stock = tts.generate_stock(8604)

mad_filter = MovingAverageDirectionFilter.new(span: 20)
mad_filter.stock = stock
mad_filter.calculate_indicators

# 以下のデータは、2010/01/04 2010/06/14のもの
real_filters = [nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
nil,nil,nil,nil,nil,nil,nil,nil,nil,:long_only,:short_only,
:short_only,:short_only,:short_only,:short_only,:short_only,
:short_only,:short_only,:short_only,:short_only,:short_only,
:short_only,:short_only,:short_only,:short_only,:short_only,
:short_only,:short_only,:short_only,:short_only,:short_only,
:short_only,:long_only,:long_only,:long_only,:long_only,
:long_only,:long_only,:long_only,:long_only,:long_only,
:long_only,:long_only,:long_only,:long_only,:long_only,
:long_only,:long_only,:long_only,:long_only,:long_only,
:long_only,:long_only,:long_only,:long_only,:long_only,
:long_only,:long_only,:long_only,:long_only,:long_only,
:short_only,:long_only,:short_only,:short_only,:short_only,
:short_only,:short_only,:short_only,:short_only,:short_only,
:short_only,:short_only,:short_only,:short_only,:short_only,
:short_only,:short_only,:short_only,:short_only,:short_only,
:short_only,:short_only,:short_only,:short_only,:short_only,
:short_only,:short_only,:short_only,:short_only,:short_only,
:short_only,:short_only,:short_only,:short_only,:short_only,
:short_only,:short_only]

real_filters.each_with_index do |real_filter, i|
  filter = mad_filter.get_filter(i + 1)
  puts "#{real_filter || 'nil'}  #{filter || 'nil'}"
  puts "fail in data #{i}\n" unless real_filter == filter
end

puts
p mad_filter.get_filter(0)   #=> nil
