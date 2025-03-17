require "./lib/stock_list_maker"

# 東証銘柄の銘柄リストを作る
# 使い方：ruby bin\make_stock_list.rb file_name
# file_nameは省略可。省略すると"tosho_list.txt"になる

slm = StockListMaker.new(:t)
slm.file_name = ARGV[0] || "tosho_list.txt"
puts slm.file_name
(1300..9999).each do |code|
  slm.get_stock_info(code)
end
slm.save_stock_list
