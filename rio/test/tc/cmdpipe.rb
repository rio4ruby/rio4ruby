#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'

class TC_cmdpipe < Test::RIO::TestCase
  @@once = false
  @@dname = 'd'
  @@fnames = ['f0','f1','f2','g0','g1']

  require 'tc/programs_util'
  include Test::RIO::Programs

  def self.once
    @@once = true
    rio(@@dname).rmtree.mkpath.chdir {
      @@fnames.each { |fn|
        make_lines_file(20,fn)
      }
    }
  end
  def setup
    super
    self.class.once unless @@once
  end

  def test_cmd_out
    #$trace_states = true
    ls = rio(?-,PROG[:list_dir]+' d')
    out = rio("cmd_out.txt").chomp
    exp = @@fnames
    rtn = ls | out
    assert_equal(exp,out.lines[])
    #assert_equal(rtn,out)
  end

  def test_cmd_out_file
    #$trace_states = true
    ls = rio(?-,PROG[:list_dir]+' d')
    outfile = 'cmd_out_file.txt'
    out = rio(outfile).abs
    exp = @@fnames.map{|f| f+$/}
    rtn = ls | out
    #p out
    #p out.exist?
    #p out.closed?
    #out.close
    #out.lines do |ln|
    #  puts ln
    #end
    assert_equal(exp,rio(outfile).lines[])
    #assert_equal(rtn,out)
  end

  def atest_cmd_out_file_show
    #$trace_states = true
    outfile = 'cmd_out_file.txt'
    out = rio(outfile)
    p out
    p out.exist?
    rio(outfile).lines do |ln|
      puts ln
    end
  end

  def test_cmd_cmd_out
    ls = rio(?-,PROG[:list_dir]+' d')
    grep = rio(?-,PROG[:find_lines]+' f')
    #out = rio(?").chomp
    out = rio('cmd_cmd_out.txt').chomp
    exp = @@fnames.select { |fn| fn =~ /f/ }
    rtn = ls | grep | out
    #p out[]
    assert_equal(exp,out[])
    #assert_equal(rtn,out)
  end

  def test_cmd_cmd_cmd_out
    ls = rio(?-,PROG[:list_dir]+' d')
    cmd = rio(?-,PROG[:find_lines]+' f')
    cmd2 = rio(?-,PROG[:find_lines]+' 1')
    out = rio('cmd_cmd_cmd_out.txt').chomp
    exp = @@fnames.select { |fn| fn =~ /f1/ }
    rtn = ls | cmd | cmd2 | out
    assert_equal(exp,out[])
    # assert_equal(rtn,out)
  end

  def test_file_out
    inp = rio('d/f2')
    out = rio("file_out.txt")
    rtn = inp | out
    exp = inp[]
    assert_equal(exp,out[])
    # assert_equal(rtn,out)
  end

  def test_file_cmd_out
    inp = rio('d/f2')
    cmd = rio(?-,PROG[:find_lines]+' 1')
    out = rio("file_cmd_out.txt")
    rtn = inp | cmd | out
    exp = inp[/1/]
    assert_equal(exp,out[])
    #assert_equal(rtn,out)
  end

  def test_file_cmd_cmd_out
    inp = rio('d/f2')
    cmd = rio(?-,PROG[:find_lines]+' 1')
    cmd2 = rio(?-,PROG[:find_lines]+' 0')
    out = rio("file_cmd_cmd_out.txt")
    rtn = inp | cmd | cmd2 | out
    exp = inp[/10/]
    assert_equal(exp,out[])
    #assert_equal(rtn,out)
  end

  def test_file_cmdpipe_out2
    inp = rio('d/f2')
    cmd = rio(?-,PROG[:find_lines]+' 1')
    cmd2 = rio(?-,PROG[:find_lines]+' 0')

    cmdpipe = inp | cmd | cmd2
    assert_equal('cmdpipe',cmdpipe.scheme)

    out = rio("file_cmdpipe_out2.txt")
    rtn = cmdpipe | out
    exp = inp[/10/]
    assert_equal(exp,out[])
    #assert_equal(rtn,out)

    out = rio("file_cmdpipe_out2.txt")
    rtn = cmdpipe | out
    exp = inp[/10/]
    assert_equal(exp,out[])
    #assert_equal(rtn,out)
  end

  def dbg_trace_states(tf=true,&block)
    old_trace_states = $trace_states
    begin
      $trace_states = tf
      yield
    ensure
      $trace_states = old_trace_states
    end
  end


  def test_file_cmdpipe_out
    inp = rio('d/f2')
    cmd = rio(?-,PROG[:find_lines]+' 1')
    cmd2 = rio(?-,PROG[:find_lines]+' 0')
    out = rio("file_cmdpipe_out.txt")

    cmdpipe = cmd | cmd2
    p "test_file_cmdpipe_out: #{cmdpipe.inspect}"
    assert_equal('cmdpipe',cmdpipe.scheme)

    dbg_trace_states(false) do
      rtn = inp | cmdpipe | out
      exp = inp[/10/]
      assert_equal(exp,out[])
      #assert_equal(rtn,out)
    end
  end

  def atest_cmdpipe_without
    $trace_states = true
    cmd = rio(?-,PROG[:find_lines]+' 1')
    cmd2 = rio(?-,PROG[:find_lines]+' 0')
    out = rio(?")

    cmdpipe = rio(?|,cmd,cmd2,out)
    assert_equal('cmdpipe',cmdpipe.scheme)

    inp = rio('d/f2')
    rtn = inp | cmdpipe
    #exp = inp[/10/]
    #assert_equal(exp,out[])
    #assert_equal(rtn,out)

#     inp = rio('d/f1')
#     rtn = inp | cmdpipe
#     exp = inp[[/1/,/0/]]
#     assert_equal(exp,out[])
#     #assert_equal(rtn,out)

  end

end
