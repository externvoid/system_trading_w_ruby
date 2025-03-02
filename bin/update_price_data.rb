 # coding: Windows-31J

require "./lib/stock_data_getter"

# 東証銘柄をダウンロードする。
# 名証銘柄をダウンロードしたければ、market = :n とする
# 福証なら market = :f、札証なら market = :s

from = "1983/01/4"
to   = Date.today.to_s
market = :t
ydg = StockDataGetter.new(from, to, market)

(1300..9999).each do |code|
  ydg.update_price_data(code)
end
