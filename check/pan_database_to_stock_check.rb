require "./lib/pan_database_to_stock"

pdts = PanDatabaseToStock.new(stock_list:
                              "data/tosho_list.txt",
                              market_section: "東証1部")

stock = pdts.generate_stock(1301)
puts stock.code                   #=> 1301
puts stock.dates.first
puts stock.open_prices.first

pdts.each_stock do |stock|
  puts stock.code
end                               #=> 1301, 1332, 1334, ...

# 開始日と終了日を指定
pdts.from = "2011/01/04"
pdts.to   = "2011/06/30"

pdts.each_stock do |stock|
  puts [stock.code, stock.dates.first, stock.dates.last].join(" ")
end

# 株式分割への対応
# ファーストリテイリング 2002/02/25に1:2の株式分割
pdts = PanDatabaseToStock.new(stock_list: "data/tosho_list.txt",
                              market_section: "東証1部",
                              adjust_ex_rights: true)
pdts.from = "2002/01/04"
pdts.to   = "2002/02/28"
stock = pdts.generate_stock(9983)
index = stock.dates.index("2002/02/22")
puts stock.open_prices[index]     #=> 2510
                                  # :adjust_ex_rights が false なら5020
index = stock.dates.index("2002/02/25")
puts stock.open_prices[index]     #=> 2545
