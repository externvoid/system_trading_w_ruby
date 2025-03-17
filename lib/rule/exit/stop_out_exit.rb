require "./lib/base"

# ストップアウトクラス
# 価格がストップに掛かったら手仕舞う
# ストップに掛かった瞬間、即座に手仕舞う
# 寄付きで掛かったら寄付きで、
# 場中に掛かったら場中に手仕舞う
class StopOutExit < Exit
  def check_long(trade, index)
    stop = trade.stop
    price = @stock.prices[index]
    return unless stop >= price[:low]
    price, time = if stop >= price[:open]
                    [price[:open], :open]
                  else
                    [stop, :in_session]
                  end
    exit(trade, index, price, time)
  end

  def check_short(trade, index)
    stop = trade.stop
    price = @stock.prices[index]
    return unless stop <= price[:high]
    price, time = if stop <= price[:open]
                    [price[:open], :open]
                  else
                    [stop, :in_session]
                  end
    exit(trade, index, price, time)
  end
end
