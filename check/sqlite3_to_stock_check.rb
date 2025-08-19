require "./lib/sqlite3_to_stock"

tts = TextToStock.new(data_dir:       "data",
                      stock_list:     "stock.db",
                      market_section: "東証PRM")

stock = tts.generate_stock(1301)
puts stock.code               #=> 1301
puts stock.dates.first        #=> "2010/01/04"
puts stock.open_prices.first  #=> 185

tts.each_stock do |stock|
  puts stock.code
end                           #=> 1301, 1332, 1334, ...

# 開始日と終了日を指定
tts.from = "2011/01/04" #.gsub('/', '-')
tts.to   = "2011/06/30" #.gsub('/', '-')

tts.each_stock do |stock|
  puts [stock.code, stock.dates.first, stock.dates.last].join(" ")
end
# 1301 2011-01-04 2011-06-30
# 1332 2011-01-04 2011-06-30
# 1333
