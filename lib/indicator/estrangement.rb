
require "./lib/base"

# 移動平均乖離率クラス
class Estrangement < Indicator
  def initialize(stock, params)
    @stock = stock
    @span = params[:span]
  end

  def calculate_indicator
    @stock.close_prices.map_indicator(@span) do |prices|
      moving_average = prices.average
      (prices.last - moving_average) / moving_average * 100
    end
  end
end
