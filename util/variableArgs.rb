def foo(*sections)
  return unless sections[0]
  sections.each do |e|
    puts e
  end
end

foo
foo ["OK", "NG"]
