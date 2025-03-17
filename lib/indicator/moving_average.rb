require "./lib/base"

# 移動平均クラス
# 始値、高値、安値、終値
#（:open, :high, :low, :close）のうちどれでも
# :price_atパラメーターを指定しなければ、終値で計算する
class MovingAverage < Indicator
  def initialize(stock, params)
    @stock = stock
    @span = params[:span]
    @price_at = params[:price_at] || :close
  end

  def calculate_indicator
    prices = @stock.send(@price_at.to_s + "_prices")
    prices.moving_average(@span)
  end
end
