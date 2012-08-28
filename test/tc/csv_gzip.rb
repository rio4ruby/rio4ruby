#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'
require 'tc/csvutil'

class TC_csv_gzip < Test::RIO::TestCase
  include CSV_Util

  @@once = false
  def self.once
    @@once = true
  end
  def setup()
    super
    @src = rio(?")
    @dst_name = 'dst.csv'
    @records,@strings,@lines,@string = create_test_csv_data(@src,3, 3, ',', $/, true)
    if $USE_FASTER_CSV
      opts = {:headers => true, :return_headers => true}
      @rows = []
      ::CSV.parse(@string, opts) do |row|
        @rows << row
      end
    else
      @rows = []
      @records.each do |rec|
        h = {}
        (0...rec.size).each do |n|
          h["Col#{n}"] = rec[n]
        end
        @rows << h
      end
    end
      
  end

  def test_basic
    rio('basic.csv') < @string
    assert_equal(@string,File.read('basic.csv'))
    rio('basic.csv').csv > rio('basic.csv.gz').csv.gzip
    assert_equal(@lines, rio('basic.csv.gz').csv.gzip.lines[])    
    assert_equal(@records, rio('basic.csv.gz').csv.gzip.records[])
    assert_equal(@rows[1...@rows.size], rio('basic.csv.gz').csv.gzip.rows[])

    rio('basic.csv.gz').csv.gzip < rio('basic.csv').csv
    assert_equal(@lines, rio('basic.csv.gz').csv.gzip.lines[])    
    assert_equal(@records, rio('basic.csv.gz').csv.gzip.records[])
    assert_equal(@rows[1...@rows.size], rio('basic.csv.gz').csv.gzip.rows[])
  end

  def test_copy
    rio('copy.csv') < @string
    assert_equal(@string,File.read('copy.csv'))

    rio('copy.csv').csv > rio('copy.csv.gz').csv.gzip
    rio('copy.csv.gz').csv.gzip > rio('out.csv').csv
    assert_equal(@lines, rio('out.csv').csv.lines[])    

    rio('out1.csv.gz').csv.gzip < rio('copy.csv.gz').csv.gzip
    assert_equal(@lines, rio('out1.csv.gz').csv.gzip.lines[])    
    rio('copy.csv.gz').csv.gzip > rio('out2.csv.gz').csv.gzip 
    assert_equal(@string, rio('out2.csv.gz').gzip.contents)    

    csv_arg = ($USE_FASTER_CSV ? {:col_sep => ';'} : ';')
    rio('out3.csv.gz').csv(csv_arg).gzip < rio('copy.csv.gz').csv.gzip
    assert_equal(@string.gsub(',',';'), rio('out3.csv.gz').gzip.contents)    
    rio('copy.csv.gz').csv.gzip > rio('out4.csv.gz').csv(csv_arg).gzip 
    assert_equal(@string.gsub(',',';'), rio('out4.csv.gz').gzip.contents)    

  end


end
