#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'

class TC_cmdio < Test::RIO::TestCase
  @@once = false
  def self.once
    @@once = true
    make_test_files
  end
  def setup()
    super
    self.class.once unless @@once
  end

  DNAME_F = 'df'
  FNAMES_F = ['f0','f1','f2']
  DNAME_G = 'dg'
  FNAMES_G = ['g0','g1']
  N_LINES = 20

  require 'tc/programs_util'
  include Test::RIO::Programs

  def self.make_test_files
    rio(DNAME_F).rmtree.mkpath.chdir {
      FNAMES_F.each { |fn|
        rio(fn) < (1..N_LINES).map{ |n| "Line #{n} of #{fn}\n" }
      }
    }
    rio(DNAME_G).rmtree.mkpath.chdir {
      FNAMES_G.each { |fn|
        rio(fn) < (1..N_LINES).map{ |n| "Line #{n} of #{fn}\n" }
      }
    }
  end


  def test_new_noargs
    # $trace_states = true
    cmd = 'ls'
    exp = "cmdio:"+cmd
    r1 = rio(:-,cmd)
    assert_equal(exp,r1.uri.to_s)
    r2 = rio("cmdio:"+cmd)
    assert_equal(exp,r2.uri.to_s)
    assert_equal r1,r2
  end

  def test_new_cmd_noargs
    # $trace_states = true
    cmd = 'ls'
    r1 = rio(:-,cmd)
    assert_equal(cmd,r1.cmd)
    assert_nil(r1.cmd_args)
    r2 = rio("cmdio:"+cmd)
    assert_equal(cmd,r2.cmd)
    assert_nil(r2.cmd_args)
    assert_equal r1,r2
  end

  def test_new_cmd_str
    # $trace_states = true
    cmd = 'wc -l'
    r1 = rio(:-,cmd)
    assert_equal(cmd,r1.cmd)
    assert_nil(r1.cmd_args)
    r2 = rio("cmdio:"+cmd.gsub(/ /,'%20'))
    assert_equal(cmd,r2.cmd)
    assert_nil(r2.cmd_args)
    assert_equal r1,r2
  end
  def test_new_cmd_arg
    # $trace_states = true
    cmd = 'wc'
    arg = '-l'
    r1 = rio(:-,cmd,arg)
    assert_equal(cmd,r1.cmd)
    assert_equal(arg,r1.cmd_args)
    r2 = rio("cmdio:#{cmd}?#{arg}")
    assert_equal(cmd,r2.cmd)
    assert_equal(arg,r2.cmd_args)
    assert_equal r1,r2
  end

  def test_ls_noargs
    # $trace_states = true
    cmd = PROG[:list_dir]
    r = rio(:-,cmd)
    assert_equal([DNAME_F,DNAME_G].map{|el| el + $/},r[])
  end

  def test_ls_arg
    # $trace_states = true
    cmd = PROG[:list_dir]
    r = rio(:-,cmd,DNAME_F)
    assert_equal(FNAMES_F.map{|el| el + $/},r[])
  end

  def test_ls_arg_ary
    # $trace_states = true
    cmd = PROG[:list_dir]
    r = rio(:-,[cmd,DNAME_F])
    assert_equal(FNAMES_F.map{|el| el + $/},r[])
  end

  def test_ls_arg_str
    # $trace_states = true
    cmd = PROG[:list_dir]
    r = rio(:-,[cmd,DNAME_F].join(' '))
    assert_equal(FNAMES_F.map{|el| el + $/},r[])
  end

  def test_wc_copy
    # $trace_states = true
    cmd_str = PROG[:count_lines]
    f_in = rio(DNAME_G,FNAMES_G[0])
    cmd = rio(:-,'wc','-l').w!.nocloseoncopy
    f_in > cmd
    ans = cmd.close_write.chomp.gets.to_i
    assert_equal(N_LINES,ans)
  end

  def test_wc_copy2
    # $trace_states = true
    cmd_str = PROG[:count_lines]
    f_in = rio(DNAME_G,FNAMES_G[0])
    rcmd = rio(:-,'wc','-l',f_in.to_s)
    ans = rcmd.line[0].to_i
    assert_equal(N_LINES,ans)
  end

  def test_wc_copy3
    # $trace_states = true
    cmd_str = PROG[:count_lines]
    f_in = rio(DNAME_G,FNAMES_G[0])
    rcmd = rio(:-,'wc -l ' + f_in.to_s)
    ans = rcmd.line[0].to_i
    assert_equal(N_LINES,ans)
  end

  def test_wc_copy4
    # $trace_states = true
    cmd_str = PROG[:count_lines]
    f_in = rio(DNAME_G,FNAMES_G[0])
    rcmd = rio(:-,'wc','-l',f_in)
    ans = rcmd.line[0].to_i
    assert_equal(N_LINES,ans)
  end



end
