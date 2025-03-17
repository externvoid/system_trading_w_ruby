require "./lib/indicator/indicator"

class MyIndicator < Indicator
  def calculate_indicator
    [nil, nil, 3, 5, 8, 4]
  end
end

my_indicator = MyIndicator.new(nil).calculate

my_indicator.each do |ind|
  p ind
end
  #=> nil, nil, 3, 5, 8, 4
puts

puts my_indicator.first  #=> nil
puts my_indicator[2]     #=> 3
puts my_indicator[3]     #=> 5
puts

catch(:no_value) do
  puts my_indicator[0]
end
  #=> 何もしない
puts

(0..5).each do |i|
  catch(:no_value) do
    puts my_indicator[i]
  end
end
  #=> 3 5 8 4

p my_indicator[0..2]  #=> [nil, nil, 3]
p my_indicator[2..4]  #=> [3, 5, 8]
