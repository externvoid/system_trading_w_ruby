#!/usr/bin/env ruby
# ファイルをUTF-8に変換、エンコーディング指定行を削除し、改行コードを変更 
# これを一気に行うUtil

# 2025年 3月20日 木曜日 12時44分25秒 JST

# 対象となるエンコーディング指定のパターン
TARGET_PATTERN = /#.*coding:\s*Windows-31J/i

def delSomething(sjis=false)
  ruby_files = Dir.glob("**/*.rb")

  ruby_files.each do |file|
    # ファイルの内容を読み込む
    if sjis
      content = File.read(file, encoding: "Shift_JIS")
    elsif
      content = File.read(file)
    end
    yield file, content
  end
end

# delSomething(true) {|file, content|
#   begin
#     # UTF-8に変換して上書き保存
#     File.write(file, content.encode("UTF-8"))
#     
#     puts "#{file} をUTF-8に変換しました"
#   rescue => e
#     puts "#{file} の変換に失敗しました: #{e.message}"
#   end
# }
#
# delSomething {|file, content|
#   lines = content.lines
#   # 変更が必要かチェック
#   if lines.any? { |line| line =~ TARGET_PATTERN }
#     # 対象行を除外して新しい内容を作成
#     new_content = lines.reject { |line| line =~ TARGET_PATTERN }.join
#     
#     # ファイルに書き戻す
#     File.write(file, new_content)
#     puts "Delete Windows-31J : #{file}"
#   end
# }
#
# delSomething {|file, content|
#   lines = content.lines
#   if lines.first == "\r\n" then
#     lines.shift 
#     new_content = lines.join
#     # ファイルに書き戻す
#     File.write(file, new_content)
#     puts "Delete First Empty Line: #{file}"
#   end
# }

delSomething do |file, content|
  # DOS to Unix
  if content.include?("\r")
    new_content = content.gsub("\r", "")
    File.write(file, new_content)
    puts "Change CRLF to LF: #{file}"
  end
end
