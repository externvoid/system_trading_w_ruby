require "./lib/stock"
require "./lib/stock_list_dbloader"
require "sqlite3"
require "date"

# SQLiteデータベースからStockクラスのオブジェクトを生成するクラス
class TextToStock
  attr_writer :from, :to

  def initialize(params)
    @data_dir  = params[:data_dir] || raise("フォルダを指定してください")
    @stock_list  = params[:stock_list] || raise("データベースファイルを指定してください")
    @market_section = params[:market_section]
    @list_loader = StockListLoader.new("#{@data_dir}/#{@stock_list}")
  end

  # 指定されたコードの株オブジェクトを生成する
  def generate_stock(code)
    index = @list_loader.codes.index(code.to_s)
    stock = Stock.new(code.to_s,
                      market(index),
                      @list_loader.units[index])
    add_prices_from_database(stock)
    stock
  end

  # 銘柄リストにある銘柄について、
  # データベースの株価データから順番に株オブジェクトを返すイテレータ
  def each_stock
    # @list_loader.filter_by_market_section(*@market_section).codes.take(3).each do |code|
    @list_loader.filter_by_market_section(*@market_section).codes.each do |code|
       yield generate_stock(code)
       # does exist table?
       # if File.exist?("#{@data_dir}/#{code}.txt")
       # end
    end
  end

  private
  # @stock_list_infoを市場区分でフィルタリングする
  def filter_by_market_section
    return @stock_list_info unless @market_section && @market_section.any?

    @stock_list_info.select do |info|
      @market_section.include?(info[:exchange])
    end
  end

  # 市場区分の文字列をシンボルに変換する
  def market(index)
    section = @list_loader.market_sections[index]
    case section
    when /東証/
      :t
    when /名/
      :n
    when /福/
      :f
    when /札/
      :s
    else
      nil # 該当なし
    end
  end

  # DBから株価データを読み込み、stockオブジェクトに追加する
  def add_prices_from_database(stock)
    db = SQLite3::Database.new("#{@data_dir}/#{@stock_list}")

    # SQLのWHERE句で期間を絞り込む
    sql = "SELECT date, open, high, low, close, volume FROM '#{stock.code}'"
    conditions = []
    params = []

    if @from
      # conditions << "date >= \"?\""
      @from.gsub!('/', '-')
      conditions << "date >= '#{@from}'"
      # params << @from # "YYYY-MM-DD"形式を期待
    end

    if @to
      # conditions << "date <= \"?\""
      @to.gsub!('/', '-')
      conditions << "date <= '#{@to}'"
      # params << @to # "YYYY-MM-DD"形式を期待
    end

    sql += " WHERE #{conditions.join(' AND ')}" unless conditions.empty?
    sql += " ORDER BY date ASC;"

    begin
      rows = db.execute(sql) #, params)

      rows.each do |row_array|
        date = row_array[0]
        prices_and_volume = row_array[1..5] # open, high, low, close, volume
        stock.add_price(date, *prices_and_volume)
      end
    rescue SQLite3::Exception => e
      # テーブルが存在しない場合などは、価格データが空のまま処理を続ける
      # (text_to_stock.rbのFile.exist?チェックと同様の挙動)
    ensure
      db.close if db
    end
  end
end
