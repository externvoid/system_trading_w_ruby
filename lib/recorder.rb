require "./lib/trade"
require "./lib/array"
require "./lib/stats"
require "fileutils"
require "csv"

# 取引の記録を行うクラス
class Recorder
  attr_writer :record_dir

  def initialize(record_dir = nil)
    @record_dir = record_dir
  end

  # 1銘柄の取引を記録する
  def record_a_stock(trades)
    code = trades[0].stock_code
    ensure_close("#{code}.csv") do
      file_name = "#{@record_dir}/#{code}.csv"
      CSV.open(file_name, "w") do |csv_file|
        csv_file << items_for_a_stock.values
        trades.each do |trade|
          one_trade = items_for_a_stock.keys.map do |attr|
            trade.send(attr) || "-"
          end
          csv_file << one_trade
        end
      end
    end
  end

  # 銘柄ごとの統計の一覧表の作成
  def record_stats_for_each_stock(results)
    ensure_close("_stats_for_each_stock.csv") do
      CSV.open("#{@record_dir}/_stats_for_each_stock.csv", "w") do |csv_file|
        csv_file << stats_items.values.unshift("コード")
        results.each do |trades|
          csv_file << stats_array(trades).unshift(trades[0].stock_code)
        end
      end
    end
  end

  # すべてのトレードの統計
  def record_stats(results)
    ensure_close("_stats.csv") do
      CSV.open("#{@record_dir}/_stats.csv", "w") do |csv_file|
        csv_file << stats_items.values
        csv_file << stats_array(results.flatten)
      end
    end
  end

  # 設定ファイルをコピーする
  def record_setting(file_name)
    FileUtils.cp file_name, @record_dir + "/_setting.rb"
  end

  # 結果保存用のフォルダーを作る
  def create_record_folder
    if Dir.exist? @record_dir
      puts "記録フォルダ #{@record_dir} はすでに存在します。上書きしますか？ y/n"
      yes? {puts "上書きします"}
    else
      puts "記録フォルダ #{@record_dir} は存在しません。新しく作りますか？ y/n"
      yes? {FileUtils.mkdir_p @record_dir}
    end
  end

  private
  def items_for_a_stock
    { :trade_type => "取引種別",
      :entry_date => "入日付",
      :entry_price => "入値",
      :volume => "数量",
      :first_stop => "初期ストップ",
      :exit_date => "出日付",
      :exit_price => "出値",
      :profit => "損益(円)",
      :r_multiple => "R倍数",
      :percentage_result => "%損益",
      :length => "期間"}
  end

  def stats_items
    { :sum_profit => "総損益",
      :wins => "勝ち数", :losses => "負け数",
      :draws => "分け数",
      :winning_percentage => "勝率",
      :average_profit => "平均損益",
      :profit_factor => "PF",
      :sum_r => "総R倍数", :average_r => "平均R倍数",
      :sum_percentage => "総損益率",
      :average_percentage => "平均損益率",
      :average_length => "平均期間"}
  end

  def stats_array(trades)
    stats = Stats.new(trades)
    stats_items.keys.map do |stats_name|
      stats.send(stats_name) || "-"
    end
  end

  def ensure_close(file_name)
    begin
      yield
    rescue Errno::EACCES
      puts "#{file_name} が他のプログラムで書き込み禁止で開かれている可能性があります。" +
        "ファイルを閉じてからエンターキーを押してください。"
      while $stdin.gets
        retry
      end
    end
  end

  def yes?
    while answer = $stdin.gets
      if answer =~ /^[yY]/
        yield
        break
      elsif answer =~ /^[nN]/
        puts "終了します"
        exit
      else
        puts "y （はい）か n （いいえ）でお答えください"
      end
    end
  end
end
