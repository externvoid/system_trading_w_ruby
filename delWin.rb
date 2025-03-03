#!/usr/bin/env ruby

# 対象となるエンコーディング指定のパターン
TARGET_PATTERN = /#.*coding:\s*Windows-31J/i

# 現在のディレクトリとサブディレクトリから.rbファイルを再帰的に取得
ruby_files = Dir.glob("**/*.rb")

ruby_files.each do |file|
  # ファイルの内容を読み込む
  content = File.read(file)
  lines = content.lines

  # 変更が必要かチェック
  if lines.any? { |line| line =~ TARGET_PATTERN }
    # 対象行を除外して新しい内容を作成
    new_content = lines.reject { |line| line =~ TARGET_PATTERN }.join
    
    # ファイルに書き戻す
    File.write(file, new_content)
    puts "Updated: #{file}"
  end
end
