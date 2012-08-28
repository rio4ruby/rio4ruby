#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'
require 'rio/dbg/trace_states'

class TC_cmdpipe < Test::RIO::TestCase
  @@once = false

  require 'tc/programs_util'
  include Test::RIO::Programs

  DNAME_F = 'df'
  FNAMES_F = ['f0','f1','f2']
  DNAME_G = 'dg'
  FNAMES_G = ['g1','g2']
  N_LINES = 20
  OUTDIR = 'out'

  def self.once
    @@once = true
    make_test_files
  end
  def setup
    super
    self.class.once unless @@once
  end

  def self.make_test_files
    rio(DNAME_F).rmtree.mkpath.chdir {
      FNAMES_F.each { |fn|
        rio(fn) < (1..N_LINES).map{ |n| "Line #{n}\n" }
      }
    }
    rio(DNAME_G).rmtree.mkpath.chdir {
      FNAMES_G.each { |fn|
        rio(fn) < (1..N_LINES).map{ |n| "Line #{n}\n" }
      }
    }
    rio(OUTDIR).rmtree.mkdir
  end


  def test_cmd_out
    #$trace_states = true
    ls = rio(?-,PROG[:list_dir]+' '+DNAME_F)
    out = rio(OUTDIR,"cmd_out.txt").chomp
    exp = FNAMES_F
    rtn = ls | out
    assert_equal(exp,out.lines[])
    assert_equal(out,rtn)
  end

  def test_cmd_out_file
    #$trace_states = true
    ls = rio(?-,PROG[:list_dir]+' '+DNAME_F)
    outfile = 'cmd_out_file.txt'
    out = rio(OUTDIR,outfile).abs
    exp = FNAMES_F.map{|f| f+$/}
    rtn = ls | out
    assert_equal(exp,out.lines[])
    assert_equal(out,rtn)
  end

  def test_cmd_cmd_out
    ls = rio(?-,PROG[:list_dir]+' '+DNAME_F)
    grep = rio(?-,PROG[:find_lines]+' f')
    #out = rio(?").chomp
    out = rio(OUTDIR,'cmd_cmd_out.txt').chomp
    exp = FNAMES_F.select { |fn| fn =~ /f/ }
    rtn = ls | grep | out
    #p out[]
    assert_equal(exp,out[])
    assert_equal(out,rtn)
  end

  def test_cmd_cmd_cmd_out
    ls = rio(?-,PROG[:list_dir]+' '+DNAME_F)
    cmd = rio(?-,PROG[:find_lines]+' f')
    cmd2 = rio(?-,PROG[:find_lines]+' 1')
    out = rio(OUTDIR,'cmd_cmd_cmd_out.txt').chomp
    exp = FNAMES_F.select { |fn| fn =~ /f1/ }
    rtn = ls | cmd | cmd2 | out
    assert_equal(exp,out[])
    assert_equal(out,rtn)
  end

  def test_file_out
    inp = rio(DNAME_F,FNAMES_F[0])
    out = rio(OUTDIR,"file_out.txt")
    rtn = inp | out
    exp = inp[]
    assert_equal(exp,out[])
    assert_equal(out,rtn)
  end

  def test_file_cmd_out
    inp = rio(DNAME_F,FNAMES_F[0])
    cmd = rio(?-,PROG[:find_lines]+' 1')
    out = rio(OUTDIR,"file_cmd_out.txt")
    rtn = inp | cmd | out
    exp = inp[/1/]
    assert_equal(exp,out[])
    assert_equal(out,rtn)
  end

  def test_file_cmd_cmd_out
    inp = rio(DNAME_F,FNAMES_F[0])
    cmd = rio(?-,PROG[:find_lines]+' 1')
    cmd2 = rio(?-,PROG[:find_lines]+' 0')
    out = rio(OUTDIR,"file_cmd_cmd_out.txt")
    rtn = inp | cmd | cmd2 | out
    exp = inp[/10/]
    assert_equal(exp,out[])
    assert_equal(out,rtn)
  end

  def test_file_cmdpipe_out2
    inp = rio(DNAME_F,FNAMES_F[0])
    cmd = rio(?-,PROG[:find_lines]+' 1')
    cmd2 = rio(?-,PROG[:find_lines]+' 0')

    cmdpipe = inp | cmd | cmd2
    assert_equal('cmdpipe',cmdpipe.scheme)

    out = rio(OUTDIR,"file_cmdpipe_out2.txt")
    rtn = cmdpipe | out
    exp = inp[/10/]
    assert_equal(exp,out[])
    assert_equal(out,rtn)

    out = rio(OUTDIR,"file_cmdpipe_out2.txt")
    rtn = cmdpipe | out
    exp = inp[/10/]
    assert_equal(exp,out[])
    assert_equal(out,rtn)
  end



  def test_file_obj_out
    RIO::DBG::trace_states(false) do
      inp = rio(DNAME_F,FNAMES_F[0])
      cmd = rio(?-,PROG[:find_lines]+' 1')
      cmd2 = rio(?-,PROG[:find_lines]+' 0')
      out = rio(OUTDIR,"file_obj_out.txt")
      
      obj = cmd | cmd2
      # p "test_file_obj_out: #{obj.inspect}"
      assert_equal('cmdpipe',obj.scheme)
      
      rtn = inp | obj | out
      exp = inp[/10/]
      assert_equal(exp,out[])
      assert_equal(out,rtn)
    end
  end

  def test_cmdpipe_without
    #$trace_states = true
    cmd = rio(?-,PROG[:find_lines]+' 1')
    cmd2 = rio(?-,PROG[:find_lines]+' 0')
    out = rio(?")

    cmdpipe = rio(?|,cmd,cmd2,out)
    assert_equal('cmdpipe',cmdpipe.scheme)

    inp = rio(DNAME_F,FNAMES_F[0])
    rtn = inp | cmdpipe
    exp = inp[[/1/,/0/]]
    assert_equal(exp,out[])
    assert_equal(out,rtn)

  end


  def test_in_cmd_out
    input = rio(:-,'ls',DNAME_G)
    output = rio(OUTDIR,'in_cmd_out.txt')
    cat = rio(:-,'cat','-n')
    input | cat | output
    assert_match(/\s+1\s+g1/,output.chomp.line[0])
    assert_match(/\s+2\s+g2/,output.chomp.line[1])
  end

  def test_in_out
    input = rio(:-,'ls')
    output = rio(OUTDIR,'in_out.txt')
    input | output
    assert_equal([DNAME_F,DNAME_G,OUTDIR], output.chomp[])
  end

  def test_cmd_cmd_obj
    input = rio(:-,'ls')
    cat1 = rio(:-,'cat','-n')
    cat2 = rio(:-,'cat','-n')
    obj = cat1 | cat2
    assert_equal('cmdpipe',obj.scheme)
    assert_equal(cat1,obj.rl.query[0])
    assert_equal(cat2,obj.rl.query[1])
  end

  def test_file_cmd_cmd_file2
    input = rio(DNAME_F,FNAMES_F[0])
    output = rio(OUTDIR,'file_obj_file.txt')
    cat1 = rio(:-,'cat','-n')
    cat2 = rio(:-,'cat','-n')
    obj = cat1 | cat2
    input | obj.rl.query[0] | obj.rl.query[1] | output
    n_lines = 3 #N_LINES
    (1..n_lines).each do |n|
      assert_match(/\s+#{n}\s+#{n}\s+Line #{n}/,output.line[n-1])
    end

  end

  def test_file_obj_file
    input = rio(DNAME_F,FNAMES_F[0])
    output = rio(OUTDIR,'file_obj_file.txt')
    cat1 = rio(:-,'cat','-n')
    cat2 = rio(:-,'cat','-n')
    obj = cat1 | cat2
    input | obj | output
    n_lines = 3 #N_LINES
    #p output[]
    (1..n_lines).each do |n|
      assert_match(/\s+#{n}\s+#{n}\s+Line #{n}/,output.line[n-1])
    end

  end

  def test_file_obj_file3
    input = rio(DNAME_F,FNAMES_F[0])
    str = ""
    strio = StringIO.new(str)
    output = rio(strio)
    cat1 = rio(:-,'cat','-n')

    obj = input | cat1
    obj | output
    n_lines = 3 #N_LINES
    (1..n_lines).each do |n|
      assert_match(/^\s+#{n}\s+Line #{n}/,output.line[n-1])
    end

  end

  def test_file_cmd_cmd_file
    input = rio(DNAME_F,FNAMES_F[0])
    output = rio(OUTDIR,'file_obj_file.txt')
    cat1 = rio(:-,'cat','-n')
    cat2 = rio(:-,'cat','-n')
    input | cat1 | cat2 | output
    n_lines = 3 #N_LINES
    (1..n_lines).each do |n|

      assert_match(/^\s+#{n}\s+#{n}\s+Line #{n}/,output.line[n-1])
    end

  end

  def test_file_obj_file2
    input = rio(DNAME_F,FNAMES_F[0])
    str = ""
    strio = StringIO.new(str)
    output = rio(strio)
    cat1 = rio(:-,'cat','-n')
    cat2 = rio(:-,'cat','-n')

    obj = cat1 | cat2
    input | obj | output
    n_lines = 3 #N_LINES
    (1..n_lines).each do |n|
      assert_match(/^\s+#{n}\s+#{n}\s+Line #{n}/,output.line[n-1])
    end

  end

  def test_file_obj_file4
    input = rio(DNAME_F,FNAMES_F[0])
    str = ""
    strio = StringIO.new(str)
    output = rio(strio)
    cat1 = rio(:-,'cat','-n')
    cat2 = rio(:-,'cat','-n')

    obj = input | cat1 | cat2
    obj | output
    n_lines = 3 #N_LINES
    (1..n_lines).each do |n|
      assert_match(/^\s+#{n}\s+#{n}\s+Line #{n}/,output.line[n-1])
    end

  end

  def test_file_obj_file5
    input = rio(DNAME_F,FNAMES_F[0])
    str = ""
    strio = StringIO.new(str)
    output = rio(strio)
    cat1 = rio(:-,'cat','-n')
    cat2 = rio(:-,'cat','-n')

    obj1 = cat1 | cat2
    obj2 = input | obj1
    obj2 | output
    n_lines = 3 #N_LINES
    (1..n_lines).each do |n|
      assert_match(/^\s+#{n}\s+#{n}\s+Line #{n}/,output.line[n-1])
    end

  end


  def test_file_obj_file6
    input = rio(DNAME_F,FNAMES_F[0])
    str = ""
    strio = StringIO.new(str)
    output = rio(strio)
    cat1 = rio(:-,'cat','-n')
    cat2 = rio(:-,'cat','-n')
    cat3 = rio(:-,'cat','-n')

    obj1 = cat1 | cat2
    obj2 = obj1 | cat3

    input | obj2 | output

    n_lines = 3 #N_LINES
    (1..n_lines).each do |n|
      assert_match(/^\s+#{n}\s+#{n}\s+#{n}\s+Line #{n}/,output.line[n-1])
    end

  end





end
