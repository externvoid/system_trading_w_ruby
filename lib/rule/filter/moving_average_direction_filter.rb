require "./lib/base"

# 移動平均の方向フィルタークラス
# 前日の移動平均が上昇中のときは、買いからのみ入る
# 前日の移動平均が下降中のときは、売りからのみ入る
# 前日の移動平均が横ばいのときは、仕掛けない
class MovingAverageDirectionFilter < Filter
  def initialize(params)
    @span = params[:span]
  end

  def calculate_indicators
    @moving_average_direction = MovingAverageDirection.new(@stock, span: @span).calculate
  end

  def filter(index)
    case @moving_average_direction[index - 1]
    when :up
      :long_only
    when :down
      :short_only
    when :flat
      :no_entry
    end
  end
end
