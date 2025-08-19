section = "名証PRM"
a = case section
    when /東/
      :t
    when /名/
      :n
    when /福/
      :f
    when /札/
      :s
    else
      nil # 該当なし
    end
puts a # => n
