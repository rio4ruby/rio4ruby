#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'
require 'tc/csvutil'

class TC_csv < Test::RIO::TestCase
  include CSV_Util

  @@once = false
  def self.once
    @@once = true
  end
  def setup()
    super
    @src_name = 'src1.csv'
    @dst_name = 'dst.csv'
    @records,@strings,@lines,@string = create_test_csv_data(@src_name,3, 3, ',', $/, true)
  end
  def test_nocsv_lines
    rio(@src_name) > rio(@dst_name)
    assert_equal(@string,rio(@dst_name).contents)
    assert_equal(@lines,rio(@dst_name)[])
    assert_equal(@strings,rio(@dst_name).chomp[])
    assert_equal(@lines,rio(@dst_name).to_a)
    assert_equal(@strings,rio(@dst_name).chomp.to_a)
    assert_equal(@lines,rio(@dst_name).readlines)
    assert_equal(@strings,rio(@dst_name).chomp.readlines)
  end
  def test_csv_lines
    assert_equal(@string,rio(@dst_name).csv.contents)
    assert_equal(@records,rio(@dst_name).csv[])
    assert_equal(@records,rio(@dst_name).csv.chomp[])
    assert_equal(@lines,rio(@dst_name).csv.lines[])
    assert_equal(@strings,rio(@dst_name).csv.chomp.lines[])
    assert_equal(@records,rio(@dst_name).csv.records[])
    assert_equal(@lines,rio(@dst_name).csv.records.readlines)
    assert_equal(@lines[1..2],rio(@dst_name).csv.lines[1..2])
    assert_equal(@lines[1..2],rio(@dst_name).csv.lines(1..2).to_a)
    assert_equal(@lines,rio(@dst_name).csv.lines(1..2).readlines)
  end
  def test_kind_new
    mkrio = proc { rio(@src_name).csv }
    each_kind_csv(mkrio)
  end
  def test_kind_reuse
    src = rio(@src_name).csv
    mkrio = proc { src }
    each_kind_csv(mkrio)

  end
  def test_each_break
    each_break
  end
  def test_each_kind
    each_kind
  end
  def each_break()
    
    recs2 = create_test_csv_records(2, 2, true)
    ary = records_to_strings(recs2)
    rio('src2.csv') < records_to_string(recs2)
    
    
    ario = rio('src2.csv').chomp
    ario.each { |el| assert_equal(ary[0],el); break }
    ario.each { |el| assert_equal(ary[1],el); break }
    
    ario = rio('src2.csv').chomp
    ario.each { |el| assert_equal(ary[0],el); break }
    ario.each_record { |el| assert_equal(ary[1],el); break }
    
    ario = rio('src2.csv').chomp
    ario.each { |el| assert_equal(ary[0],el); break }
    ario.each_row { |el| assert_equal(ary[1],el); break }
    
    ario = rio('src2.csv').chomp
    ario.each_record { |el| assert_equal(ary[0],el); break }
    ario.each { |el| assert_equal(ary[1],el); break }
    
    ario = rio('src2.csv').chomp
    ario.each_record { |el| assert_equal(ary[0],el); break }
    ario.each_record { |el| assert_equal(ary[1],el); break }
    
    ario = rio('src2.csv').chomp
    ario.each_record { |el| assert_equal(ary[0],el); break }
    ario.each_row { |el| assert_equal(ary[1],el); break }
    
    ario = rio('src2.csv').chomp
    ario.each_row { |el| assert_equal(ary[0],el); break }
    ario.each { |el| assert_equal(ary[1],el); break }
    
    ario = rio('src2.csv').chomp
    ario.each_row { |el| assert_equal(ary[0],el); break }
    ario.each_record { |el| assert_equal(ary[1],el); break }
    
    ario = rio('src2.csv').chomp
    ario.each_row { |el| assert_equal(ary[0],el); break }
    ario.each_row { |el| assert_equal(ary[1],el); break }
    
  end
  def each_kind()
    mkrio = proc { rio('src1.csv') }
    
    rio('src1.csv').each                 { |el| assert_kind_of(::String,el); break }
    rio('src1.csv').each_record          { |el| assert_kind_of(::String,el); break }
    rio('src1.csv').each_row             { |el| assert_kind_of(::String,el); break }
    
    rio('src1.csv').lines.each           { |el| assert_kind_of(::String,el); break }
    rio('src1.csv').lines.each_record    { |el| assert_kind_of(::String,el); break }
    rio('src1.csv').lines.each_row       { |el| assert_kind_of(::String,el); break }
    
    rio('src1.csv').records.each         { |el| assert_kind_of(::String,el); break }
    rio('src1.csv').records.each_record  { |el| assert_kind_of(::String,el); break }
    rio('src1.csv').records.each_row     { |el| assert_kind_of(::String,el); break }
    
    rio('src1.csv').rows.each            { |el| assert_kind_of(::String,el); break }
    rio('src1.csv').rows.each_record     { |el| assert_kind_of(::String,el); break }
    rio('src1.csv').rows.each_row        { |el| assert_kind_of(::String,el); break }
  end
  def each_kind_csv(mkrio)
    
    mkrio.call.each         { |el| assert_kind_of(::Array,el); break }
    mkrio.call.each_record  { |el| assert_kind_of(::Array,el); break }
    mkrio.call.each_row     { |el| assert_kind_of(::Hash,el); break }
    
    mkrio.call.lines.each         { |el| assert_kind_of(::String,el); break }
    mkrio.call.lines.each_record  { |el| assert_kind_of(::String,el); break }
    mkrio.call.lines.each_row     { |el| assert_kind_of(::Hash,el); break }
    
    mkrio.call.records.each         { |el| assert_kind_of(::Array,el); break }
    mkrio.call.records.each_record  { |el| assert_kind_of(::Array,el); break }
    mkrio.call.records.each_row     { |el| assert_kind_of(::Hash,el); break }
    
    mkrio.call.rows.each         { |el| assert_kind_of(::Hash,el); break }
    mkrio.call.rows.each_record  { |el| assert_kind_of(::Hash,el); break }
    mkrio.call.rows.each_row     { |el| assert_kind_of(::Hash,el); break }
  end
  def test_copy
    rio('dst.csv') < @string
    assert_equal(@lines,::File.open('dst.csv').readlines)
    
    rio('dst.csv').csv < @string
    assert_equal(@lines,::File.open('dst.csv').readlines)
    
    rio('dst.csv') < @lines
    assert_equal(@lines,::File.open('dst.csv').readlines)
    
    rio('dst.csv').csv < @records
    assert_equal(@lines,::File.open('dst.csv').readlines)

    src_str = @string.dup

    rio(?",src_str) >  rio(?",dst_str='')
    assert_equal(src_str,dst_str)

    rio(?",src_str).csv >  rio(?",dst_str='')
    assert_equal(@records.join,dst_str)

    rio(?",dst_str='') < rio(?",src_str).csv
    assert_equal(@records.join,dst_str)

    dst = rio(?")
    rio(?",src_str) > dst.csv
    assert_equal(@records,dst[])

    dst = rio(?")
    dst.csv < rio(?",src_str)
    assert_equal(@records,dst[])

    dst = rio(?")
    rio(?",src_str) > dst.csv
    assert_equal(@records,dst[])

    dst = rio(?").csv < rio(?",src_str)
    assert_equal(@records,dst[])

    dst = rio(?").csv(';') < rio(?",src_str).csv
    assert_equal(src_str.gsub(/,/,';'),dst.contents)
    $trace_states = false
    rio(?",src_str).csv > (dst = rio(?").csv(';'))
    assert_equal(src_str.gsub(/,/,';'),dst.contents)
    $trace_states = false

  end
end
