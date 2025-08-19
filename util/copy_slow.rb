require 'sqlite3'
require 'fileutils'

# --- 設定 ---
# コピー元のデータベースファイル
SOURCE_DBS = ['data/n225Hist.db', 'data/crawling.db']
# コピー先のデータベースファイル
DEST_DB = 'data/stock.db'
# コピー対象とするテーブル名の正規表現（英数4文字）
TABLE_NAME_PATTERN = /^[a-zA-Z0-9]{4}$/

# --- メイン処理 ---
puts "データベースのコピー処理を開始します。"

begin
  # コピー先データベースに接続（ファイルがなければ新規作成）
  dest_db = SQLite3::Database.new(DEST_DB)
  puts "コピー先データベースに接続しました: #{DEST_DB}"

  SOURCE_DBS.each do |source_db_path|
    unless File.exist?(source_db_path)
      puts "警告: コピー元データベースが見つかりません: #{source_db_path}。スキップします。"
      next
    end

    # コピー元データベースに接続
    source_db = SQLite3::Database.new(source_db_path)
    puts "コピー元データベースを処理中: #{source_db_path}"

    # コピー対象のテーブル名を取得
    tables = source_db.execute("SELECT name FROM sqlite_master WHERE type='table'").flatten.select do |name|
      name.match?(TABLE_NAME_PATTERN)
    end

    if tables.empty?
      puts "  -> コピー対象のテーブルが見つかりませんでした。"
      source_db.close
      next
    end
    
    puts "  -> #{tables.size}個のテーブルをコピーします: #{tables.join(', ')}"

    tables.each do |table_name|
      # 1. テーブルを作成 (IF NOT EXISTS)
      # スキーマは指定されたものに固定
      create_sql = <<-SQL
        CREATE TABLE IF NOT EXISTS '#{table_name}' (
          date   TEXT PRIMARY KEY,
          open   REAL,
          high   REAL,
          low    REAL,
          close  REAL,
          volume REAL,
          adj    REAL
        );
      SQL
      dest_db.execute(create_sql)

      # 2. コピー元からデータをすべて選択
      rows = source_db.execute("SELECT * FROM '#{table_name}'")

      # 3. コピー先にデータを挿入 (トランザクションで高速化)
      if rows.any?
        dest_db.transaction do
          # 主キー(date)が重複した場合は無視する (INSERT OR IGNORE)
          insert_sql = "INSERT OR IGNORE INTO '#{table_name}' (date, open, high, low, close, volume, adj) VALUES (?, ?, ?, ?, ?, ?, ?)"
          stmt = dest_db.prepare(insert_sql)
          rows.each do |row|
            stmt.execute(row)
          end
          stmt.close
        end
        puts "    - テーブル'#{table_name}'から#{rows.size}件のレコードをコピーしました。"
      else
        puts "    - テーブル'#{table_name}'にレコードはありませんでした。"
      end
    end

    source_db.close
  end

rescue SQLite3::Exception => e
  puts "エラーが発生しました: #{e}"
ensure
  dest_db.close if dest_db
  puts "処理が完了しました。"
end
