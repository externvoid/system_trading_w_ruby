Dir["./lib/{indicator,rule}/**/*.rb"].each do |file|
  class_name = File.basename(file, ".rb")
                   .split("_")
                   .map{|s| s.capitalize}
                   .join("")
  autoload class_name, file
end
