require "./lib/base"

# ブレイクアウト仕掛けクラス
# n日高値安値のブレイクで買い仕掛け、売り仕掛け
class BreakoutEntry < Entry
  include Breakout

  # 高値をブレイクしたら買い仕掛け
  # 寄付きでブレイクした場合は始値、
  # ザラ場でブレイクした場合はn日高値の1ティック上で買う
  def check_long(index)
    if break_high?(index)
      enter_long(index, *price_and_time_for_break_high(index))
    end
  end

  # 安値をブレイクしたら売り仕掛け
  # 寄付きでブレイクした場合は始値、
  # ザラ場でブレイクした場合はn日安値の1ティック下で売る
  def check_short(index)
    if break_low?(index)
      enter_short(index, *price_and_time_for_break_low(index))
    end
  end
end
