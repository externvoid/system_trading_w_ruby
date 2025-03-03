
require "./lib/base"

# MinHoldExitクラス
# ポジション保有日数がｎ日以下のときは、手仕舞わない
class MinHoldExit < Exit
  def initialize(params)
    @min_hold_days = params[:min_hold_days]
  end

  def check_exit(trade, index)
    return :no_exit if trade.length <= @min_hold_days
  end
end
