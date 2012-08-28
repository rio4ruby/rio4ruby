#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require 'rio'
require 'test/unit'

#require 'test/unit/testsuite'

class TC_RIO_each < Test::Unit::TestCase
  def setup
    rio($QPDIR,'test_each').rmtree.mkpath.chdir do
      f = rio('basic.txt')
      0.upto(6) do |n|
        f.puts("L#{n+1}: #{n*3}:#{n*2}")
      end
      f.puts!("Line Z")
    end
  end

  def test_basic
    rio($QPDIR,'test_each').chdir do

      expa = ["L1: 0:0\n", "L2: 3:2\n", "L3: 6:4\n", "L4: 9:6\n", "L5: 12:8\n", "L6: 15:10\n", "L7: 18:12\n",
        "Line Z\n"]

      ans = []

      rio('basic.txt').lines { |line| ans.push(line) }
      assert_equal(expa,ans)
      ans.clear

      rio('basic.txt').lines.each { |line| ans.push(line) }
      assert_equal(expa,ans)
      ans.clear

      rio('basic.txt').each { |line| ans.push(line) }
      assert_equal(expa,ans)
      ans.clear

      # proxy of IO#each_line -- lines() is ignored
      rio('basic.txt').each_line { |line| ans.push(line) }
      assert_equal(expa,ans)
      ans.clear

      assert_equal(expa,rio('basic.txt').lines.to_a)
      assert_equal(expa,rio('basic.txt').to_a)

      ans = rio('basic.txt').lines(1..3).to_a
      assert_equal(expa[1..3],ans)
      ans = rio('basic.txt').lines(1..1,5..6).to_a
      assert_equal(expa[1..1] + expa[5..6],ans)
      ans = rio('basic.txt').lines(1,5..6).to_a
      assert_equal(expa[1..1] + expa[5..6],ans)

      assert_equal([expa[1],expa[4],expa[6]],rio('basic.txt').lines(/2/).to_a)

      ans = []
      rio('basic.txt').chomp.lines(/2/).each { |line| ans.push(line) }
      assert_equal([expa[1],expa[4],expa[6]].map{|el| el.chomp},ans)

      ans = []
      rio('basic.txt').chomp.lines(/2/) { |line| ans.push(line) }
      assert_equal([expa[1],expa[4],expa[6]].map{|el| el.chomp},ans)

      ans = []
      rio('basic.txt').lines(/2/).chomp { |line| ans.push(line) }
      assert_equal([expa[1],expa[4],expa[6]].map{|el| el.chomp},ans)
    end
  end

  def test_bytes
    rio($QPDIR,'test_each').chdir do
      eol = (($mswin32 || $mingw32) && RUBY_VERSION >= "1.9") ? "\r\n" : "\n"
      nbytes = 32

      str = "L1: 0:0#{eol}L2: 3:2#{eol}L3: 6:4#{eol}L4: 9:6#{eol}L5: 12:8#{eol}L6: 15:10#{eol}L7: 18:12#{eol}Line Z#{eol}"
      expb = []
      (0..2).each do |n|
        expb << str[nbytes*n,nbytes]
      end
       
      assert_equal(expb,rio('basic.txt').bytes(nbytes).to_a)
      assert_equal(expb[0..1],rio('basic.txt').records(0..1).bytes(nbytes).to_a)
      assert_equal(expb[0..1],rio('basic.txt').bytes(nbytes).records(0..1).to_a)

      ans = []
      rio('basic.txt').bytes(nbytes) { |rec| ans << rec }
      assert_equal(expb,ans)

      ans = []
      rio('basic.txt').bytes(nbytes).each { |rec| ans << rec }
      assert_equal(expb,ans)

      ans = []
      rio('basic.txt').records(1..2).bytes(nbytes).each { |rec| ans << rec }
      assert_equal(expb[1..2],ans)

      ans = []
      rio('basic.txt').records(1..2).bytes(nbytes) { |rec| ans << rec }
      assert_equal(expb[1..2],ans)

      ans = []
      rio('basic.txt').bytes(nbytes).records(1..2).each { |rec| ans << rec }
      assert_equal(expb[1..2],ans)

      ans = []
      rio('basic.txt').bytes(nbytes).records(1..2) { |rec| ans << rec }
      assert_equal(expb[1..2],ans)

      assert_equal(expb[0..2],rio('basic.txt').bytes(nbytes).records(0..2).to_a)

      #      expc = [["15", "10"], ["18", "12"]]
      #      assert_equal(expc,rio('basic.txt').lines(/(\d\d):(\d\d)/).to_a)

      #      ans = []
      #      rio('basic.txt').lines(/(\d\d):(\d\d)/) { |ary|
      #        ans.push(ary)
      #      }
      #      assert_equal(expc,ans)

    end
  end
end

