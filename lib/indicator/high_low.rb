require "./lib/base"

# 区間の高値安値クラス
# 4本値それぞれの高値・安値に対応
class HighLow < Indicator
  def initialize(stock, params)
    @stock = stock
    @span = params[:span]
    @high_low = params[:high_low]
    @price_at = params[:price_at] || params[:high_low]
  end

  def calculate_indicator
    prices = @stock.map_prices(@price_at)
    prices.send(@high_low.to_s + "s", @span)
  end
end
