#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'
require 'tc/csvutil'

class TC_csv_columns < Test::RIO::TestCase
  include CSV_Util

  @@once = false
  def self.once
    @@once = true
  end
  def setup()
    super
    @src = rio(?")
    @dst_name = 'dst.csv'
    @records,@strings,@lines,@string = create_test_csv_data(@src,3, 8,',',$/, true)
    if $USE_FASTER_CSV
      opts = {:headers => true, :return_headers => true}
      @rows = []
      ::CSV.parse(@string, opts) do |row|
        @rows << row
      end
    end
  end

  def col_recs(r,cola)
    ans = []
    r.each do |rec|
      row = []
      cola.each do |col|
        row << rec[col]
      end
      ans << row.flatten
    end
    ans
  end
  def test_basic

    rio('src1.csv') < @src
    r = @records
    assert_equal(col_recs(r,[1,2,5]),rio('src1.csv').csv.columns(1,2,5).to_a)
    assert_equal(col_recs(r,(3...6).to_a),rio('src1.csv').csv.columns(3...6).to_a)
    assert_equal(col_recs(r,[3,5]),rio('src1.csv').csv.columns(3...6).skipcolumns(4).to_a)
    assert_equal(col_recs(r,[0,7]),rio('src1.csv').csv.skipcolumns(1..6).to_a)
    assert_equal([[],[],[],[]],rio('src1.csv').csv.skipcolumns.to_a)
    assert_equal(r,rio('src1.csv').csv.columns.to_a)
    
  end

  def test_neg_recs

    rio('src1.csv') < @src
    r = @records
    assert_equal(col_recs(r,[7]),rio('src1.csv').csv.columns(-1).to_a)
    assert_equal(col_recs(r,[6]),rio('src1.csv').csv.columns(-2).to_a)
    assert_equal(col_recs(r,[0..7]),rio('src1.csv').csv.columns(0..-1).to_a)
    assert_equal(col_recs(r,[0..6]),rio('src1.csv').csv.columns(0..-2).to_a)
    assert_equal(col_recs(r,[0...7]),rio('src1.csv').csv.columns(0...-1).to_a)
    assert_equal(col_recs(r,[0...6]),rio('src1.csv').csv.columns(0...-2).to_a)

    assert_equal(col_recs(r,[3..7]),rio('src1.csv').csv.columns(-5..-1).to_a)
    assert_equal(col_recs(r,[3..6]),rio('src1.csv').csv.columns(-5..-2).to_a)
    assert_equal(col_recs(r,[3...7]),rio('src1.csv').csv.columns(-5...-1).to_a)
    assert_equal(col_recs(r,[3...6]),rio('src1.csv').csv.columns(-5...-2).to_a)

    assert_equal(col_recs(r,[3..6]),rio('src1.csv').csv.columns(-5..6).to_a)
    assert_equal(col_recs(r,[3..7]),rio('src1.csv').csv.columns(-5..7).to_a)
    assert_equal(col_recs(r,[3..7]),rio('src1.csv').csv.columns(-5..8).to_a)
    assert_equal(col_recs(r,[3..7]),rio('src1.csv').csv.columns(-5..9).to_a)
    
    assert_equal(col_recs(r,[3...6]),rio('src1.csv').csv.columns(-5...6).to_a)
    assert_equal(col_recs(r,[3...7]),rio('src1.csv').csv.columns(-5...7).to_a)
    assert_equal(col_recs(r,[3...8]),rio('src1.csv').csv.columns(-5...8).to_a)
    assert_equal(col_recs(r,[3...8]),rio('src1.csv').csv.columns(-5...9).to_a)
    
    assert_equal(col_recs(r,[7..6]),rio('src1.csv').csv.columns(-1..6).to_a)
    assert_equal(col_recs(r,[7..7]),rio('src1.csv').csv.columns(-1..7).to_a)
    assert_equal(col_recs(r,[7..8]),rio('src1.csv').csv.columns(-1..8).to_a)
    assert_equal(col_recs(r,[7..9]),rio('src1.csv').csv.columns(-1..9).to_a)
    
    assert_equal(col_recs(r,[7...6]),rio('src1.csv').csv.columns(-1...6).to_a)
    assert_equal(col_recs(r,[7...7]),rio('src1.csv').csv.columns(-1...7).to_a)
    assert_equal(col_recs(r,[7...8]),rio('src1.csv').csv.columns(-1...8).to_a)
    assert_equal(col_recs(r,[7...9]),rio('src1.csv').csv.columns(-1...9).to_a)
    
    assert_equal(col_recs(r,[7..2]),rio('src1.csv').csv.columns(-1..-6).to_a)
    assert_equal(col_recs(r,[7..1]),rio('src1.csv').csv.columns(-1..-7).to_a)
    assert_equal(col_recs(r,[7..0]),rio('src1.csv').csv.columns(-1..-8).to_a)
    assert_equal(col_recs(r,[]),rio('src1.csv').csv.columns(-1..-9).to_a)
    
  end

  def col_lines(r,cola)
    ans = []
    col_recs(r,cola).each do |recs|
      ans << ::CSV::generate_line(recs)
    end
    ans
  end

  def test_lines
    if $USE_FASTER_CSV
      rio('src1.csv') < @src
      r = @records
      assert_equal(col_lines(r,[1,2,5]),rio('src1.csv').csv.columns(1,2,5).lines[])
      assert_equal(col_lines(r,(3...6).to_a),rio('src1.csv').csv.columns(3...6).lines[])
      assert_equal(col_lines(r,[3,5]),rio('src1.csv').csv.columns(3...6).skipcolumns(4).lines[])
      assert_equal(col_lines(r,[0,7]),rio('src1.csv').csv.skipcolumns(1..6).lines[])
      assert_equal(["\n","\n","\n","\n"],rio('src1.csv').csv.skipcolumns.lines[])
      assert_equal(col_lines(r,(0...r[0].size).to_a),rio('src1.csv').csv.columns.lines[])
    end
  end

  def test_neg_lines

    rio('src1.csv') < @src
    r = @records
    assert_equal(col_lines(r,[7]),rio('src1.csv').csv.columns(-1).lines[])
    assert_equal(col_lines(r,[6]),rio('src1.csv').csv.columns(-2).lines[])
    assert_equal(col_lines(r,[0..7]),rio('src1.csv').csv.columns(0..-1).lines[])
    assert_equal(col_lines(r,[0..6]),rio('src1.csv').csv.columns(0..-2).lines[])
    assert_equal(col_lines(r,[0...7]),rio('src1.csv').csv.columns(0...-1).lines[])
    assert_equal(col_lines(r,[0...6]),rio('src1.csv').csv.columns(0...-2).lines[])

    assert_equal(col_lines(r,[3..7]),rio('src1.csv').csv.columns(-5..-1).lines[])
    assert_equal(col_lines(r,[3..6]),rio('src1.csv').csv.columns(-5..-2).lines[])
    assert_equal(col_lines(r,[3...7]),rio('src1.csv').csv.columns(-5...-1).lines[])
    assert_equal(col_lines(r,[3...6]),rio('src1.csv').csv.columns(-5...-2).lines[])

    assert_equal(col_lines(r,[3..6]),rio('src1.csv').csv.columns(-5..6).lines[])
    assert_equal(col_lines(r,[3..7]),rio('src1.csv').csv.columns(-5..7).lines[])
    assert_equal(col_lines(r,[3..7]),rio('src1.csv').csv.columns(-5..8).lines[])
    assert_equal(col_lines(r,[3..7]),rio('src1.csv').csv.columns(-5..9).lines[])
    
    assert_equal(col_lines(r,[3...6]),rio('src1.csv').csv.columns(-5...6).lines[])
    assert_equal(col_lines(r,[3...7]),rio('src1.csv').csv.columns(-5...7).lines[])
    assert_equal(col_lines(r,[3...8]),rio('src1.csv').csv.columns(-5...8).lines[])
    assert_equal(col_lines(r,[3...8]),rio('src1.csv').csv.columns(-5...9).lines[])
    
    assert_equal(col_lines(r,[7..6]),rio('src1.csv').csv.columns(-1..6).lines[])
    assert_equal(col_lines(r,[7..7]),rio('src1.csv').csv.columns(-1..7).lines[])
    assert_equal(col_lines(r,[7..8]),rio('src1.csv').csv.columns(-1..8).lines[])
    assert_equal(col_lines(r,[7..9]),rio('src1.csv').csv.columns(-1..9).lines[])
    
    assert_equal(col_lines(r,[7...6]),rio('src1.csv').csv.columns(-1...6).lines[])
    assert_equal(col_lines(r,[7...7]),rio('src1.csv').csv.columns(-1...7).lines[])
    assert_equal(col_lines(r,[7...8]),rio('src1.csv').csv.columns(-1...8).lines[])
    assert_equal(col_lines(r,[7...9]),rio('src1.csv').csv.columns(-1...9).lines[])
    
    assert_equal(col_lines(r,[7..2]),rio('src1.csv').csv.columns(-1..-6).lines[])
    assert_equal(col_lines(r,[7..1]),rio('src1.csv').csv.columns(-1..-7).lines[])
    assert_equal(col_lines(r,[7..0]),rio('src1.csv').csv.columns(-1..-8).lines[])
    assert_equal(col_lines(r,[]),rio('src1.csv').csv.columns(-1..-9).lines[])
    
  end

  def col_rows(r,cola)
    ans = []
    col_recs(r,cola).each_with_index do |recs,i|
      #p recs
      if $USE_FASTER_CSV
        ans << ::CSV::Row.new(cola.map{|n| r[0][n]},recs,i==0)
      else
        h = {}
        recs.each_with_index do |rec,n|
          #p rec,n
          h["Col#{cola[n]}"]  = rec
        end
        ans << h
      end
    end
    first_row = ($USE_FASTER_CSV ? 1 : 0)
    ans[first_row,r.size-first_row]
  end

  def test_rows
    rio('src1.csv') < @src
    r = @records
    assert_equal(col_rows(r,[1,2,5]),rio('src1.csv').csv.columns(1,2,5).rows[])
    assert_equal(col_rows(r,(3...6).to_a),rio('src1.csv').csv.columns(3...6).rows[])
    assert_equal(col_rows(r,[3,5]),rio('src1.csv').csv.columns(3...6).skipcolumns(4).rows[])
    assert_equal(col_rows(r,[0,7]),rio('src1.csv').csv.skipcolumns(1..6).rows[])
    assert_equal(col_rows(r,[]),rio('src1.csv').csv.skipcolumns(3...8,1,0..4).rows[])
    assert_equal(col_rows(r,[]),rio('src1.csv').csv.skipcolumns.rows[])
    assert_equal(col_rows(r,(0...r[0].size).to_a),rio('src1.csv').csv.columns.rows[])
  end

  def test_neg_rows

    rio('src1.csv') < @src
    r = @records
    assert_equal(col_rows(r,[7]),rio('src1.csv').csv.columns(-1).rows[])
    assert_equal(col_rows(r,[6]),rio('src1.csv').csv.columns(-2).rows[])
    assert_equal(col_rows(r,(0..7).to_a),rio('src1.csv').csv.columns(0..-1).rows[])
    assert_equal(col_rows(r,(0..6).to_a),rio('src1.csv').csv.columns(0..-2).rows[])
    assert_equal(col_rows(r,(0...7).to_a),rio('src1.csv').csv.columns(0...-1).rows[])
    assert_equal(col_rows(r,(0...6).to_a),rio('src1.csv').csv.columns(0...-2).rows[])

    assert_equal(col_rows(r,(3..7).to_a),rio('src1.csv').csv.columns(-5..-1).rows[])
    assert_equal(col_rows(r,(3..6).to_a),rio('src1.csv').csv.columns(-5..-2).rows[])
    assert_equal(col_rows(r,(3...7).to_a),rio('src1.csv').csv.columns(-5...-1).rows[])
    assert_equal(col_rows(r,(3...6).to_a),rio('src1.csv').csv.columns(-5...-2).rows[])

    assert_equal(col_rows(r,(3..6).to_a),rio('src1.csv').csv.columns(-5..6).rows[])
    assert_equal(col_rows(r,(3..7).to_a),rio('src1.csv').csv.columns(-5..7).rows[])
    assert_equal(col_rows(r,(3..7).to_a),rio('src1.csv').csv.columns(-5..8).rows[])
    assert_equal(col_rows(r,(3..7).to_a),rio('src1.csv').csv.columns(-5..9).rows[])
    
    assert_equal(col_rows(r,(3...6).to_a),rio('src1.csv').csv.columns(-5...6).rows[])
    assert_equal(col_rows(r,(3...7).to_a),rio('src1.csv').csv.columns(-5...7).rows[])
    assert_equal(col_rows(r,(3...8).to_a),rio('src1.csv').csv.columns(-5...8).rows[])
    assert_equal(col_rows(r,(3...8).to_a),rio('src1.csv').csv.columns(-5...9).rows[])
    
    assert_equal(col_rows(r,(7..6).to_a),rio('src1.csv').csv.columns(-1..6).rows[])
    assert_equal(col_rows(r,(7..7).to_a),rio('src1.csv').csv.columns(-1..7).rows[])
    assert_equal(col_rows(r,(7..7).to_a),rio('src1.csv').csv.columns(-1..8).rows[])
    assert_equal(col_rows(r,(7..7).to_a),rio('src1.csv').csv.columns(-1..9).rows[])
    
    assert_equal(col_rows(r,(7...6).to_a),rio('src1.csv').csv.columns(-1...6).rows[])
    assert_equal(col_rows(r,(7...7).to_a),rio('src1.csv').csv.columns(-1...7).rows[])
    assert_equal(col_rows(r,(7...8).to_a),rio('src1.csv').csv.columns(-1...8).rows[])
    assert_equal(col_rows(r,(7...8).to_a),rio('src1.csv').csv.columns(-1...9).rows[])
    
    assert_equal(col_rows(r,(7..2).to_a),rio('src1.csv').csv.columns(-1..-6).rows[])
    assert_equal(col_rows(r,(7..1).to_a),rio('src1.csv').csv.columns(-1..-7).rows[])
    assert_equal(col_rows(r,(7..0).to_a),rio('src1.csv').csv.columns(-1..-8).rows[])
    assert_equal(col_rows(r,[]),rio('src1.csv').csv.columns(-1..-9).rows[])
    
  end



end
