#!/usr/bin/env ruby
# :set list@vim, to see LF or CR

# 現在のディレクトリとサブディレクトリから.rbファイルを再帰的に取得
ruby_files = Dir.glob("**/*.rb")

ruby_files.each do |file|
  # ファイルの内容を読み込む
  content = File.read(file)
  lines = content.lines
  if lines.first == "\r\n" then
    lines.shift 
    new_content = lines.join
    # ファイルに書き戻す
    File.write(file, new_content)
    puts "Updated: #{file}"
  end
end
