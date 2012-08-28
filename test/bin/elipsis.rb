# encoding:  UTF-8

chars = %w[a é …]
chars.each do |char|
  p char.bytes.map { |b| b.to_s(2) }
end
#$ ruby_dev utf8_bytes.rb 
#["1100001"]
#["11000011", "10101001"]
#["11100010", "10000000", "10100110"]
  