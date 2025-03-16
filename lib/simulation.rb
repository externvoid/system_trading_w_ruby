require "./lib/trading_system"
require "./lib/recorder"

# 売買シミュレーションを行うクラス
class Simulation
  def initialize(params = {})
    @trading_system = params[:trading_system]
    @data_loader    = params[:data_loader]
    @recorder       = params[:recorder]
    @from           = params[:from]
    @to             = params[:to]
    @record_every_stock = if params[:record_every_stock] == false
                            false
                          else
                            true
                          end
  end

  # 1銘柄のシミュレーションを行う
  def simulate_a_stock(code)
    set_dates_to_data_loader
    stock = @data_loader.generate_stock(code)
    simulate(stock)
    @recorder.record_a_stock(@trades) unless @trades.empty?
  end

  # すべての銘柄のシミュレーションを行う
  def simulate_all_stocks
    results = []
    set_dates_to_data_loader
    @data_loader.each_stock do |stock|
      simulate(stock)
      puts stock.code
      next if @trades.empty?
      if @record_every_stock
        @recorder.record_a_stock(@trades)
      end
      results << @trades
    end
    @recorder.record_stats_for_each_stock(results)
    @recorder.record_stats(results)
  end

  private
  def set_dates_to_data_loader
    @data_loader.from = @from
    @data_loader.to   = @to
  end

  def simulate(stock)
    @trading_system.set_stock(stock)
    @trading_system.calculate_indicators
    @trades = []
    @position = nil
    @unit = stock.unit
    stock.prices.size.times do |index|
      @index = index
      before_open
      at_open
      in_session
      at_close
    end
  end

  def before_open
    @signal = nil
    return unless @position
    @position.exit_date = nil
    @position.exit_price = nil
    @trading_system.set_stop(@position, @index)
    @position.length += 1
  end

  def at_open
    take_position(:open)
    close_position(:open)
  end

  def in_session
    take_position(:in_session)
    close_position(:in_session)
  end

  def at_close
    take_position(:close)
    close_position(:close)
  end

  def take_position(entry_time)
    return if @position
    @signal ||= @trading_system.check_entry(@index)
    return unless @signal
    if @signal.entry_time == entry_time
      @position = @signal
      @position.volume = @unit
      @signal = nil
    end
  end

  def close_position(exit_time)
    return unless @position
    unless @position.closed?
      @trading_system.check_exit(@position, @index)
    end
    return unless @position.closed?
    if @position.exit_time == exit_time
      @trades << @position
      @position = nil
    end
  end
end
