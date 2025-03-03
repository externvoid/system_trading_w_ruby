
require "open-uri"

# Yahooの銘柄情報ページから情報を取得し、
# 銘柄リストを作るクラス
# 証券コード、上場市場、単元株数・売買単位が含まれる
class StockListMaker
  attr_accessor :data_dir, :file_name

  def initialize(market)
    @market = market
    @data_dir = "data"
    @stock_info = []
  end

  # 銘柄情報の取得
  def get_stock_info(code)
    page = open_page(code)
    return unless page
    text = page.read.encode("Windows-31J", :undef => :replace)
    data = parse(text)
    data[:code] = code
    return unless data[:market_section]
    puts code
    @stock_info << data
  end

  # 銘柄情報の保存
  def save_stock_list
    File.open(@data_dir + "/" + @file_name, "w") do |file|
      @stock_info.each do |data|
        file.puts [data[:code], data[:market_section], data[:unit]].join(",")
      end
    end
  end

  private
  # 銘柄情報ページを開く
  def open_page(code)
    begin
      open("http://stocks.finance.yahoo.co.jp/stocks/detail/?code=#{code}.#{@market}")
    rescue OpenURI::HTTPError
      return
    end
  end

  # HTMLから銘柄情報を抜き出す
  def parse(text)
    data = Hash.new
    sections = []
    reg_market = /"stockMainTabName">([^< ]+)</
    reg_unit = %r!<dd class="ymuiEditLink mar0"><strong>((?:\d|,)+|---)</strong>株</dd>!
    text.lines do |line|
      if line =~ reg_market
        sections << $+
      elsif line =~ reg_unit
        data[:market_section] = sections[0]
        data[:unit] = get_unit($+)
        return data
      end
    end
    data
  end

  # 単位株数を得る
  def get_unit(str)
    if str == "---"
      "1"
    else
      str.gsub(/,/,"")
    end
  end
end
