#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'
require 'tc/csvutil'

class TC_csv_headers < Test::RIO::TestCase
  include CSV_Util

  @@once = false
  def self.once
    @@once = true
  end

  def setup()
    super
    @src = rio(?")
    @dst_name = 'dst.csv'
    @records,@strings,@lines,@string = create_test_csv_data(@src,2, 5,',',$/, true)
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
    rio('basic.csv') < @src
    r = @records
    assert_equal(r[0,3],rio('basic.csv').csv[])
    assert_equal(r[1,2],rio('basic.csv').csv.headers.records[])
    assert_equal([r[0]],rio('basic.csv').csv.headers?)
    
    assert_equal(r[0,3],rio('basic.csv').csv(:return_headers => true).headers.records[])
    
    heads = (0..2).map{|n| "HEAD#{n}"}
    assert_equal(r[0,3],rio('basic.csv').csv.headers(heads).records[])
    assert_equal(heads,rio('basic.csv').csv.headers(heads).headers?)
    assert_equal([heads] + r[0,3],rio('basic.csv').csv(:return_headers => true).headers(heads).records[])
    
  end

  def test_num_columns
    rio('columns.csv') < @src
    r = @records
    exp = r.map{|el| [el[1]]}
    assert_equal(exp,rio('columns.csv').csv.columns(1)[])
    exp = r[1,2].map{|el| [el[1]]}
    assert_equal(exp,rio('columns.csv').csv.headers.columns(1)[])
    heads = (0..2).map{|n| "HEAD#{n}"}
    exp = r.map{|el| [el[1]]}
    assert_equal(exp,rio('columns.csv').csv.headers(heads).columns(1).records[])
    exp = [["HEAD1"]] + exp
    assert_equal(exp,rio('basic.csv').csv(:return_headers => true).headers(heads).columns(1).records[])

#    p rio('columns.csv').csv.headers(heads).records[]
  end
  def col_rows(r,cola,heads=nil)
    ans = []
    col_recs(r,cola).each_with_index do |recs,i|
      #p recs
      if $USE_FASTER_CSV
        heads ||= cola.map{|n| r[0][n]}
        ans << ::CSV::Row.new(heads,recs,i==0)
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

  def test_named_columns
    rio('fields.csv') < @src
    r = @records
    exp = col_rows(r,[1,2,3,4])
    #assert_equal(exp,rio('fields.csv').csv.columns(1).rows[])
    exp = col_rows(r,[1,2,3,4])
    assert_equal(exp,rio('fields.csv').csv.columns('Head1'..'Head4').rows[])
    exp = col_rows(r,[1,2,4])
    assert_equal(exp,rio('fields.csv').csv.columns('Head1'..'Head4').skipcolumns('Head3').rows[])
    exp = col_rows(r,[3,4])
    assert_equal(exp,rio('fields.csv').csv.columns('Head1'..'Head4').skipcolumns('Head0'...'Head3').rows[])

#    p rio('fields.csv').csv.headers(heads).records[]
  end

  def test_mixed_columns
    rio('mixed.csv') < @src
    r = @records
    exp = col_rows(r,[1,2,3])
    assert_equal(exp,rio('mixed.csv').csv.columns('Head1'..'Head3').rows[])
    assert_equal(exp,rio('mixed.csv').csv.columns('Head1'...'Head4').rows[])
    assert_equal(exp,rio('mixed.csv').csv.columns('Head1',2,'Head3'...'Head4').rows[])
    assert_equal(exp,rio('mixed.csv').csv.columns('Head2',1...4).rows[])
    assert_equal(exp,rio('mixed.csv').csv.columns('Head0'..'Head4').skipcolumns(0,'Head4').rows[])

  end

  def test_external_columns
    rio('external.csv') < @src
    r = @records
    heads = (0..4).map{|n| "HEAD#{n}"}
    exp = col_rows([heads] + r[0,3],[0,1,2,3,4],heads)
    assert_equal(exp,rio('external.csv').csv.headers(heads).rows[])
    exp = col_rows([heads[1,3]] + r[0,3],[1,2,3],heads[1,3])
    assert_equal(exp,rio('external.csv').csv.headers(heads).columns('HEAD1'..'HEAD3').rows[])
  end


end
