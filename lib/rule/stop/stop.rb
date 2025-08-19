require "./lib/base"

# ストップクラス
class Stop < Rule
  def get_stop(position, index)
    with_valid_indicators do
      if position.long?
        stop_price_long(position, index)
      elsif position.short?
        stop_price_short(position, index)
      end
    end
  end
end
