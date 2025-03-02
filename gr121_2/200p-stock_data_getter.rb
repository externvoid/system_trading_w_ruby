# coding: Windows-31J

require "open-uri"
require "date"

# Yahoo!ファイナンスから株価データをダウンロードするクラス
class StockDataGetter
  attr_accessor :data_dir

  def initialize(from, to, market)
    @from_date = Date.parse(from)
    @to_date   = Date.parse(to)
    @market = market
    @data_dir = "data"
  end

  # 株価データの新規取得
  def get_price_data(code)
    @code = code
    save_to_file(prices_text)
  end

  # 株価データの日々更新
  def update_price_data(code)
    @code = code
    if File.exist?(data_file_name)
      get_from_date
      append_to_file(prices_text)
    else
      save_to_file(prices_text)
    end
  end

  private
  # ファイルに記録される文字列
  def prices_text
    prices = get_price_data_from_historical_data_pages
    return if prices.empty?
    prices_to_text(prices)
  end

  # 時系列データのページを読み込む
  def get_price_data_from_historical_data_pages
    page_num = 1
    prices = []
    begin
      url = url_for_historical_data(page_num)
      begin
        text = open(url).read.encode("Windows-31J", :undef => :replace)
      rescue EOFError
        return []
      end
      prices += text.scan(reg_prices)
      page_num += 1
    end  while text =~ %r!次へ</a></ul>!
    prices
  end

  # 時系列データのURL
  def url_for_historical_data(page_num)
    "http://info.finance.yahoo.co.jp/history/" +
      "?code=#{@code}.#{@market}" +
      "&sy=#{@from_date.year}" +
      "&sm=#{@from_date.month}&sd=#{@from_date.day}" +
      "&ey=#{@to_date.year}" +
      "&em=#{@to_date.month}&ed=#{@to_date.day}" +
      "&tm=d&p=#{page_num}"
  end

  # 株価データ表から株価データを取り出すための
  # 正規表現パターン
  def reg_prices
    %r!<td>(\d{4}年\d{1,2}月\d{1,2}日)</td><td>((?:\d|,)+(?:\.\d+)?)</td><td>((?:\d|,)+(?:\.\d+)?)</td><td>((?:\d|,)+(?:\.\d+)?)</td><td>((?:\d|,)+(?:\.\d+)?)</td><td>((?:\d|,)+)</td><td>((?:\d|,)+(?:\.\d+)?)</td>!
  end

  # 株価データの配列を文字列に変換
  def prices_to_text(prices)
    new_prices = prices.reverse.map do |price|
      # price[0]は日付
      # 年月日の文字を取り除き"/"で区切る
      price[0].gsub!(/[年月]/, "\/")
      price[0].gsub!(/日/, "")
      # 1桁の月や日を0で始まる二桁の数字に
      price[0].gsub!(%r!/(\d)/!, '/0\1/')
      price[0].gsub!(%r!/(\d)$!, '/0\1')
      # price[1..6]は値段と出来高
      # 数字の間にあるカンマを取り除く
      price[1..6].each{|price| price.gsub!(",", "")}
      price.join(",")
    end
    new_prices.join("\n")
  end

  def data_file_name
    "#{@data_dir}/#{@code}.txt"
  end

  # ファイル中の最終日の翌日を新しい開始日とする
  def get_from_date
    last_date = File.readlines(data_file_name).last[0..9]
    @from_date = Date.parse(last_date).next
  end

  # データをテキストに保存
  def save_to_file(prices_text)
    save(prices_text, "w")
  end

  # 既存のファイルにデータを追加
  def append_to_file(prices_text)
    save(prices_text, "a")
  end

  def save(prices_text, open_mode)
    return unless prices_text
    File.open(data_file_name, open_mode) do |file|
      file.puts prices_text
    end
    puts @code
  end
end
