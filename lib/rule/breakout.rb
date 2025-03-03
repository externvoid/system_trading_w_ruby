
require "./lib/base"

# ブレイクアウトモジュール
module Breakout
  def initialize(params)
    @span = params[:span]
  end

  def calculate_indicators
    @highs =
      HighLow.new(@stock, span: @span, high_low: :high).calculate
    @lows  = 
      HighLow.new(@stock, span: @span, high_low: :low).calculate
  end

  def break_high?(index)
    @stock.high_prices[index] > @highs[index - 1]
  end

  def break_low?(index)
    @stock.low_prices[index] < @lows[index - 1]
  end

  def price_and_time_for_break_high(index)
    open_price = @stock.open_prices[index]
    highest_high = @highs[index - 1]
    if open_price > highest_high
      [open_price, :open]
    else
      [Tick.up(highest_high), :in_session]
    end
  end

  def price_and_time_for_break_low(index)
    open_price = @stock.open_prices[index]
    lowest_low = @lows[index - 1]
    if open_price < lowest_low
      [open_price, :open]
    else
      [Tick.down(lowest_low), :in_session]
    end
  end
end
