require "./lib/base"

# ブレイクアウト手仕舞いクラス
# n日高値安値のブレイクで手仕舞い買い、手仕舞い売り
class BreakoutExit < Exit
  include Breakout

  # 安値をブレイクしたら手仕舞い売り
  # 寄付きでブレイクした場合は始値、
  # ザラ場でブレイクした場合はn日安値の1ティック下で売る
  def check_long(trade, index)
    if break_low?(index)
      exit(trade, index, *price_and_time_for_break_low(index))
    end
  end

  # 高値をブレイクしたら買戻し
  # 寄付きでブレイクした場合は始値、
  # ザラ場でブレイクした場合はn日高値の1ティック上で買い戻す
  def check_short(trade, index)
    if break_high?(index)
      exit(trade, index, *price_and_time_for_break_high(index))
    end
  end
end
