# encoding: UTF-8

#require 'rio'
str = "Résumé"
puts "#{str.encoding.name}: #{str}"
ents = Dir.entries('data').grep(/^[^.]/)
ents.each do |d|
  puts "#{d.encoding.name}: #{d}"
end
strf = "Résumé.txt"
puts "STRING #{strf.encoding.name}: #{strf}"
p strf.codepoints.to_a
p strf.bytes.to_a
puts
ents.each do |d|
  puts "FS #{d.encoding.name}: #{d}"
  p d.codepoints.to_a
  p d.bytes.to_a
  puts

  dir_utf8 = d.encode("UTF-8")
  puts "ENCODE #{dir_utf8.encoding.name}: #{dir_utf8}"
  p dir_utf8.codepoints.to_a
  p dir_utf8.bytes.to_a
  
  dir_forced = d.force_encoding("UTF-8")
  puts "FORCED #{dir_forced.encoding.name}: #{dir_forced}"
  p dir_forced.codepoints.to_a
  p dir_forced.bytes.to_a
  
  #s = str + "-" + dir_utf8
  #puts "#{s.encoding.name}: #{s}"
end


__END__
#puts rio('data').entries[]

chars = %w[a é …]
chars.each do |char|
  p char.bytes.map { |b| b.to_s(2) }
end
#$ ruby_dev utf8_bytes.rb 
#["1100001"]
#["11000011", "10101001"]
#["11100010", "10000000", "10100110"]
  

if __FILE__ == $0
  # TODO Generated stub
end