
require "./lib/trade"
require "./lib/array"

# Statsクラス
# 取引結果から各種統計を計算
class Stats
  def initialize(trades)
    @trades = trades
  end

  def sum_profit
    profits.sum
  end

  def average_profit
    profits.average
  end

  def wins
    profits.count{|profit| profit > 0}
  end

  def losses
    profits.count{|profit| profit < 0}
  end

  def draws
    profits.count{|profit| profit == 0}
  end

  def winning_percentage
    wins.to_f / @trades.count
  end

  def profit_factor
    if losses == 0
      nil
    else
      total_profit = profits.find_all{|profit| profit > 0}.sum.to_f
      total_loss   = profits.find_all{|profit| profit < 0}.sum.to_f
      total_profit / total_loss.abs
    end
  end

  def sum_r
    r_multiples.sum if r_multiples.any?
  end

  def average_r
    r_multiples.average if r_multiples.any?
  end

  def sum_percentage
    percentages.sum
  end

  def average_percentage
    percentages.average
  end

  def average_length
    @trades.map{|trade| trade.length}.average
  end

  private
  def profits
    @profits ||= @trades.map {|trade| trade.profit}
  end

  def r_multiples
    @r_multiples ||= @trades.map {|trade| trade.r_multiple}
  end

  def percentages
    @percentages ||= @trades.map {|trade| trade.percentage_result}
  end
end
