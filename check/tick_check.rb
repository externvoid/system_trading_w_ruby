require "./lib/tick"

puts Tick.size(100)    #=> 1
puts Tick.size(2999)   #=> 1
puts Tick.size(3000)   #=> 1
puts Tick.size(3001)   #=> 5
puts Tick.size(4000)   #=> 5
puts Tick.size(5100)   #=> 10
puts Tick.size(30000)  #=> 10
puts Tick.size(30050)  #=> 50
puts
puts Tick.truncate(99.99)  #=> 99
puts Tick.truncate(3004)   #=> 3000
puts Tick.truncate(3006)   #=> 3005
puts
puts Tick.ceil(99.99)      #=> 100
puts Tick.ceil(3004)       #=> 3005
puts Tick.ceil(3006)       #=> 3010
puts
puts Tick.round(99.99)     #=> 100
puts Tick.round(99.49)     #=> 99
puts Tick.round(3004)      #=> 3005
puts Tick.round(3002)      #=> 3000
puts
puts Tick.up(100)          #=> 101
puts Tick.up(100, 3)       #=> 103
puts Tick.up(2999, 1)      #=> 3000
puts Tick.up(2999, 2)      #=> 3005
puts Tick.up(3000)         #=> 3005
puts
puts Tick.down(100)        #=> 99
puts Tick.down(100, 3)     #=> 97
puts Tick.down(3005, 1)    #=> 3000
puts Tick.down(3005, 2)    #=> 2999
puts Tick.down(3000)       #=> 2999
puts Tick.down(3001)       #=> 2999
