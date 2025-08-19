ar = [0, 1, 2, 3].map! do |e| e.to_s end
selections = [0, 2].map! do |e| e.to_s end

br = ar.find_all do |e|
  # a = selections.include? e
  cr = selections.map do |p| e.match? p end 
  cr.include? true
  # puts cr
end
pp br
