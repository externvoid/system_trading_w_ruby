require 'sqlite3'

# --- 設定 ---
# コピー元のデータベースファイル
SOURCE_DBS = {
  n225: 'data/n225Hist.db',
  crawling: 'data/crawling.db'
}
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

  # ATTACHしたデータベースの情報を保持するハッシュ
  attached_dbs = {}

  # 1. すべてのソースデータベースをATTACHする
  SOURCE_DBS.each do |db_alias, db_path|
    unless File.exist?(db_path)
      puts "警告: コピー元データベースが見つかりません: #{db_path}。スキップします。"
      next
    end
    begin
      dest_db.execute("ATTACH DATABASE '#{db_path}' AS #{db_alias}")
      attached_dbs[db_alias] = db_path
      puts "データベースをATTACHしました: #{db_path} AS #{db_alias}"
    rescue SQLite3::Exception => e
      puts "ATTACHに失敗しました: #{db_path} (#{e.message})"
    end
  end

  # 2. ATTACHした各データベースからテーブルをコピーする
  attached_dbs.each_key do |db_alias|
    puts "アタッチされたデータベース'#{db_alias}'を処理中..."
    
    # コピー対象のテーブル名を取得
    tables = dest_db.execute("SELECT name FROM #{db_alias}.sqlite_master WHERE type='table'").flatten.select do |name|
      name.match?(TABLE_NAME_PATTERN)
    end

    if tables.empty?
      puts "  -> コピー対象のテーブルが見つかりませんでした。"
      next
    end

    puts "  -> #{tables.size}個のテーブルをコピーします: #{tables.join(', ')}"

    tables.each do |table_name|
      # a. コピー先にテーブルを作成 (IF NOT EXISTS)
      create_sql = <<-SQL
        CREATE TABLE IF NOT EXISTS "main"."#{table_name}" (
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

      # b. INSERT ... SELECT を使ってレコードをコピー
      # 主キー(date)が重複した場合は無視する (INSERT OR IGNORE)
      insert_sql = <<-SQL
        INSERT OR IGNORE INTO "main"."#{table_name}" (date, open, high, low, close, volume, adj)
        SELECT date, open, high, low, close, volume, adj FROM "#{db_alias}"."#{table_name}";
      SQL
      
      # 変更された行数を取得するために changes を使う
      dest_db.execute(insert_sql)
      changes = dest_db.changes
      if changes > 0
        puts "    - テーブル'#{table_name}'に#{changes}件の新規レコードをコピーしました。"
      else
        puts "    - テーブル'#{table_name}'のコピー対象レコードはありませんでした（すべて既存）。"
      end
    end
  end

rescue SQLite3::Exception => e
  puts "エラーが発生しました: #{e}"
ensure
  # 3. すべてのデータベースをDETACHする
  if dest_db
    attached_dbs.each_key do |db_alias|
      begin
        dest_db.execute("DETACH DATABASE #{db_alias}")
        puts "データベースをDETACHしました: #{db_alias}"
      rescue SQLite3::Exception => e
        # すでに閉じられている場合などのエラーは無視
      end
    end
    dest_db.close
    puts "データベース接続を閉じました。"
  end
  puts "処理が完了しました。"
end
