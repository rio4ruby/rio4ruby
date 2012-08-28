#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'

class TC_copydir < Test::RIO::TestCase
  @@once = false
  def self.once
    @@once = true

    rio('d0').rmtree.mkpath
    rio('d0/d2').rmtree.mkpath
    rio('d0/d3').rmtree.mkpath
    rio('d0/d4').rmtree.mkpath
    rio('d0/d2/d3').rmtree.mkpath
    rio('d0/d2/d5').rmtree.mkpath
    rio('d0/d3/d6').rmtree.mkpath
    rio('d1').rmtree.mkpath
    rio('d1/d8').rmtree.mkpath
    make_lines_file(1,'d1/f0')
    make_lines_file(2,'d1/f1')
    make_lines_file(1,'d0/f0')
    make_lines_file(2,'d0/f1')
    make_lines_file(1,'d0/d2/f0')
    make_lines_file(2,'d0/d2/f1')
    make_lines_file(1,'d0/d3/d6/f0')
    make_lines_file(2,'d0/d3/d6/f1')
  end
  def setup
    super
    self.class.once unless @@once

    @d0 = rio('d0/')
    @d1 = rio('d1/')
    @d2 = rio('d0/d2/')
    @f0 = rio('d0/f0')
    @f1 = rio('d0/f1')
    @f2 = rio('d0/d2/f2')
    @f3 = rio('d0/d2/f3')
  end
  def assert_skel_equal(exp,d,msg="")
    exp.each do |ent|
      next unless ent.dir?
      ds = rio(d,ent.filename)
      assert(ds.exist?,"entry '#{ds}' exists")
      assert_equal(ent.ftype,ds.ftype,"same ftype")
      case
      when ent.dir?
        assert_skel_equal(ent,ds,"subdirectories are the same")
      end
    end
  end
  def test_dirs_somefiles
    dst = rio('dirs_somefiles').delete!
    src = rio(@d0).files(/0/).dirs
    #$trace_states = true
    src > dst
    $trace_states = false
    ans = dst.all.map { |e| e.rel(dst) }
    exp = rio(@d0).all.map { |e| e.rel(@d0) }.select { |e| e !~ /f[^0]$/ }
    assert_array_equal(exp,ans,"dirs somefiles")
    
  end
end
