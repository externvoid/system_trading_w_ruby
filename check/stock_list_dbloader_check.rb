require "./lib/stock_list_via_sqlite3"

sll = StockListLoader.new("data/yatoday.db")

puts sll.stock_info[37] #=> {:code=>1301,
                       #    :market_section=>"東証1部",
                       #    :unit=>1000}
puts sll.codes[37]              #=> 1301
puts sll.codes.last            #=> 9997
puts sll.market_sections[37]    #=> "東証１部"
puts sll.units[37]              #=> 1000

puts sll.market_sections.include?("東証PRM")   #=> true
sll.filter_by_market_section("東証PRM")
puts sll.market_sections.include?("東証GRT")   #=> false

