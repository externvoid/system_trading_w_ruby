
require "./lib/base"

# フィルタークラス
# 仕掛けを制限する
class Filter < Rule
  def get_filter(index)
    with_valid_indicators {filter(index)}
  end
end
