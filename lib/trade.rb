# coding: Windows-31J

# 取引を表すクラス
class Trade
  attr_accessor :stock_code, :trade_type, :entry_date,
    :entry_price, :entry_time, :volume, :exit_date,
    :exit_price, :exit_time, :length, :first_stop, :stop

  # 仕掛ける
  def initialize(params)
    @stock_code  = params[:stock_code]
    @trade_type  = params[:trade_type]
    @entry_date  = params[:entry_date]
    @entry_price = params[:entry_price]
    @volume      = params[:volume]
    @entry_time  = params[:entry_time]
    @length = 1
  end

  # 手仕舞う
  def exit(params)
    @exit_date  = params[:exit_date]  || params[:date]
    @exit_price = params[:exit_price] || params[:price]
    @exit_time  = params[:exit_time]  || params[:time]
  end

  # 手仕舞い済みかどうか
  def closed?
    if @exit_date && @exit_price
      true
    else
      false
    end
  end

  # 買いトレードかどうか
  def long?
    @trade_type == :long
  end

  # 売りトレードかどうか
  def short?
    @trade_type == :short
  end

  # 損益金額
  def profit
    plain_result * @volume
  end

  # %損益
  def percentage_result
    (plain_result.to_f / @entry_price) * 100
  end

  # R
  def r
    return unless @first_stop
    if long?
      @entry_price - @first_stop
    elsif short?
      @first_stop - @entry_price
    end
  end

  # R倍数
  def r_multiple
    return unless @first_stop
    return if r == 0
    plain_result.to_f / r.to_f
  end

  private
  # 株数を掛けない損益
  def plain_result
    if long?
      @exit_price - @entry_price
    elsif short?
      @entry_price - @exit_price
    end
  end
end
