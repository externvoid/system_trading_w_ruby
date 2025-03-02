
# 必要なライブラリを読み込み
require 'fileutils'

# 現在のディレクトリとサブディレクトリ内の.rbファイルを再帰的に取得
Dir.glob("**/*.rb") do |file_path|
  begin
    # ファイルの内容をShift_JISとして読み込む
    content = File.read(file_path, encoding: "Shift_JIS")
    
    # UTF-8に変換して上書き保存
    File.write(file_path, content.encode("UTF-8"))
    
    puts "#{file_path} をUTF-8に変換しました"
  rescue => e
    puts "#{file_path} の変換に失敗しました: #{e.message}"
  end
end
