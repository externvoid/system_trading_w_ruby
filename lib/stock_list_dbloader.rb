require 'sqlite3'

# SQLite3データベースから銘柄リストを読み込み、銘柄に関する情報を供給するクラス
class StockListLoader
  def initialize(database_file)
    unless database_file
      raise "データベースファイルを指定してください"
    end
    db = SQLite3::Database.new(database_file)
    sql = "SELECT code, exchange FROM codeTbl"
    # [code, exchange, 100] の配列を作成
    @stock_list = db.execute(sql).map do |row|
      [row[0], row[1], 100]
    end
    db.close
  end

  def stock_info
    @stock_info ||= @stock_list.map do |data|
      {:code => data[0], :market_section => data[1], :unit => data[2].to_i}
    end
  end

  def codes
    @codes ||= stock_info.map {|info| info[:code]}
  end

  def market_sections
    @market_sections ||= stock_info.map {|info| info[:market_section]}
  end

  def units
    @units ||= stock_info.map {|info| info[:unit]}
  end

  def filter_by_market_section(*selections)
    return self unless selections[0]
    @stock_info = stock_info.find_all do |info|
      selections.include?(info[:market_section])
    end
#  フィルタリングによってデータが変わったので、キャッシュをクリアする
    @codes = nil
    @market_sections = nil
    @units = nil
    self
  end
end
