# coding: Windows-31J

require "./lib/base"

# 移動平均乖離率による手仕舞いクラス
# 前日の終値が、n日移動平均からx%以内のとき寄付きで手仕舞う
class EstrangementExit < Exit
  def initialize(params)
    @span = params[:span]
    @rate = params[:rate]
  end

  def calculate_indicators
    @estrangement = Estrangement.new(@stock, span: @span).calculate
  end

  def check_long(trade, index)
    if @estrangement[index - 1] > (-1) * @rate
      exit(trade, index, @stock.open_prices[index], :open)
    end
  end

  def check_short(trade, index)
    if @estrangement[index - 1] < @rate
      exit(trade, index, @stock.open_prices[index], :open)
    end
  end
end
