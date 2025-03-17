require "./lib/stock"
require "./lib/stock_list_loader"
require "win32ole"

# Pan Active Market Databaseから
# Stcokクラスのオブジェクトを生成するクラス
class PanDatabaseToStock
  CANT_READ = /C1010010/
  FORWARD  = 1
  BACKWARD = -1
  CLOSED = -1
  VOLUME_ADJUSTMENT_RATE = 1000

  attr_writer :from, :to

  def initialize(params)
    @calender = WIN32OLE.new("ActiveMarket.Calendar")
    @prices   = WIN32OLE.new("ActiveMarket.Prices")
    if params[:adjust_ex_rights]
      @prices.AdjustExRights = true
    end
    @list_loader = StockListLoader.new(params[:stock_list])
    @market_section = params[:market_section]
  end

  # Pan Active Market Databaseからデータを読み込み、
  # 株オブジェクトを返す
  def generate_stock(code)
    @prices.Read(code)
    index = @list_loader.codes.index(code)
    stock = Stock.new(code,
                      market(index),
                      @list_loader.units[index])
    add_prices_from_database(stock)
    stock
  end

  # Pan Active Market Databaseにアクセスし、
  # すべての銘柄の株オブジェクトを返す
  def each_stock
    @list_loader.filter_by_market_section(*@market_section).codes.each do |code|
      begin
        yield generate_stock(code)
      rescue WIN32OLERuntimeError => e
        next if e.message =~ CANT_READ
        raise
      end
    end
  end

  private
  def market(index)
    section = @list_loader.market_sections[index]
    case section
    when /東証|マザーズ/
      :t
    when /名/
      :n
    when /福/
      :f
    when /札/
      :s
    end
  end

  def add_prices_from_database(stock)
    (from_index..to_index).each do |i|
      next if no_trade?(i)
      date = @calender.Date(i).strftime("%Y/%m/%d")
      volume = (@prices.Volume(i) * VOLUME_ADJUSTMENT_RATE).to_i
      stock.add_price(date,
                      @prices.Open(i).to_i,
                      @prices.High(i).to_i,
                      @prices.Low(i).to_i,
                      @prices.Close(i).to_i,
                      volume)

    end
  end

  def from_index
    if @from.nil? or before_begin?(@from)
      return @prices.Begin
    end
    return @prices.End + 1 if after_end?(@from)
    @calender.DatePosition(@from, FORWARD)
  end

  def to_index
    return @prices.End if @to.nil? or after_end?(@to)
    return @prices.Begin - 1 if before_begin?(@to)
    @calender.DatePosition(@to, BACKWARD)
  end

  def before_begin?(date)
    date < @calender.Date(@prices.Begin).strftime("%Y/%m/%d")
  end

  def after_end?(date)
    date > @calender.Date(@prices.End).strftime("%Y/%m/%d")
  end

  def no_trade?(index)
    @prices.IsClosed(index) == CLOSED or
      @prices.Volume(index).to_f == 0
  end
end
