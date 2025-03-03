
# トレーディングシステムの各ルールの管理をするクラス
class TradingSystem
  def initialize(rules = {})
    @entries = [rules[:entries]].flatten.compact
    @exits   = [rules[:exits]].flatten.compact
    @stops   = [rules[:stops]].flatten.compact
    @filters = [rules[:filters]].flatten.compact
  end

  def set_stock(stock)
    each_rules {|rule| rule.stock = stock}
  end

  def calculate_indicators
    each_rules {|rule| rule.calculate_indicators}
  end

  # フィルターを適用して仕掛けをチェックする
  def check_entry(index)
    trade = entry_through_filter(index)
    return unless trade
    trade_with_first_stop(trade, index)
  end

  # ストップを設定する
  def set_stop(position, index)
    position.stop = tightest_stop(position, index)
  end

  # 各手仕舞いルールを順にチェックし、
  # 最初に手仕舞いが発生した時点で手仕舞う
  # 中には、手仕舞いを制限するルールもある
  def check_exit(trade, index)
    @exits.each do |exit_rule|
      exit_filter = exit_rule.check_exit(trade, index)
      return if exit_filter == :no_exit
      return if trade.closed?
    end
  end

  private
  def each_rules
    [@entries, @exits, @stops, @filters].flatten.each do |rule|
      yield rule
    end
  end

  def entry_through_filter(index)
    case filter_signal(index)
    when :no_entry
      nil
    when :long_and_short
      check_long_entry(index) || check_short_entry(index)
    when :long_only
      check_long_entry(index)
    when :short_only
      check_short_entry(index)
    end
  end

  # すべてのフィルターをチェックして、
  # 仕掛けられる条件を絞る
  def filter_signal(index)
    filters =
      @filters.map {|filter| filter.get_filter(index)}
    return :no_entry if filters.include?(nil) ||
      filters.include?(:no_entry) ||
      (filters.include?(:long_only) &&
       filters.include?(:short_only))
    return :long_only if filters.include?(:long_only)
    return :short_only if filters.include?(:short_only)
    :long_and_short
  end

  # 各仕掛けルールを順にチェックし、
  # 最初に買い仕掛けが生じた時点で新規買トレードを返す
  # 仕掛けがなければnilを返す
  def check_long_entry(index)
    check_entry_rule(:long, index)
  end

  # 各仕掛けルールを順にチェックし、
  # 最初に売り仕掛けが生じた時点で新規売トレードを返す
  # 仕掛けがなければnilを返す
  def check_short_entry(index)
    check_entry_rule(:short, index)
  end

  def check_entry_rule(long_short, index)
    @entries.each do |entry|
      trade =
        entry.send("check_#{long_short}_entry", index)
      return trade if trade
    end
    nil
  end

  # 最もきついストップの値段を求める
  def tightest_stop(position, index)
    stops = [position.stop] +
      @stops.map {|stop| stop.get_stop(position, index)}
    stops.compact!
    if position.long?
      stops.max
    elsif position.short?
      stops.min
    end
  end

  # 仕掛けの際の初期ストップを設定する
  def trade_with_first_stop(trade, index)
    return trade if @stops.empty?
    stop = tightest_stop(trade, index)
    # まだひとつもストップがなければ仕掛けない
    return unless stop
    trade.first_stop = stop
    trade.stop = stop
    trade
  end
end
